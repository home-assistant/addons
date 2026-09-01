# Uplink Theory: the fc00::/7 Border Router Loop on Same-L2 Multi-BR Thread Networks

**Author context:** analysis prepared for the OpenThread Border Router (OTBR) multi-border-router
routing fix, submitted as a topical attachment to the Home Assistant OTBR PR.

**Topology under analysis:**
- Single-floor commercial office, 35,000+ sq ft, two physical data frames with a fiber trunk.
- The two data frames share the same VLAN set; the "two frames" detail is purely physical and
  does not affect network topology. Effectively a single L2 broadcast domain: one VLAN set with
  proper tree-like switching, one MLD querier at the root of the switching tree, static uplinks.
- One Thread network. All border routers share the same OMR prefix.
- Currently 6 border routers online (count tunable).

---

## 1. Topology classification

Single L2 broadcast domain (one VLAN set, one MLD querier, static uplinks), one Thread mesh, all
BRs sharing the OMR prefix. This is a supported same-segment multi-BR model, not a design error.
The failure comes down to one thing: the broad `fc00::/7` route that the OTBR POSIX netif layer
installs. It is not caused by prefix choices.

So the fix targets the right root cause: the loop is born from the `fc00::/7` route, not from
topology.

---

## 2. The loop mechanism (at 6 BRs specifically)

The `/7` covers `fc00::/8` + `fd00::/8` = the entire IPv6 Unique Local Address (ULA) space.
Site VLAN prefixes of the form `fd30::/64` fall inside it.

The stock code path:

1. The BR kernel installs `fc00::/7 dev wpan0`. This is the "external route" path in
   `src/posix/platform/netif.cpp`, `UpdateExternalRoutes()`, sourced from
   `RoutingManager::RoutePublisher::kUlaPrefix`.
2. A ULA packet destined for an ethernet-only VLAN enters a BR from the backbone. The kernel sees
   `/7` beating the default route (`/0`), and forwards it **into wpan0** (the Thread mesh).
3. Thread has no route to that non-OMR VLAN subnet, so the mesh hands the packet to a BR (the BR
   is the default route from the mesh's perspective).
4. That BR's host also has `fc00::/7`, so it forwards back **into the mesh**, not out the backbone.

With 2 BRs this is a 2-node ping-pong. With 6 it is a 6-node circulating loop. Hop-limit prevents
a permanent storm, but every packet that should have egressed to a VLAN instead burns its whole hop
budget inside the mesh. This is the "Thread is flaky" symptom observed over a long period.

The "uplink" concept, violated: Thread being an L2 mesh does not remove directionality from a
border router. OTBR routing is strictly two-sided:

- Thread side: the 802.15.4 `wpan0` TUN interface, the mesh, carrying the on-mesh OMR prefix.
- Infra side: the `-B` interface, the AIL (Adjacent Infrastructure Link), where the Routing
  Manager emits Router Advertisements, advertises the OMR prefix, and proxies Neighbor Discovery.

"Uplink" means toward the infra network through `-B`. Any path that lets the two sides collapse
into one plane, or that makes a BR forward a frame it just received on the infra side back onto
Thread without proper on-link/prefix adjudication, is a real violation. It produces a symmetric
forwarding loop: BR A sends to the backbone, BR B catches it and routes it back into Thread, where
it comes around to BR A again.

---

## 3. Why multi-BR is normally loop-free, and what breaks it

OpenThread's Border Routing Manager is explicitly engineered to be loop-free with multiple BRs.
The mechanism is peer detection: each BR compares the PIO/RIO prefixes it sees advertised on
the infra link (via RA) against what is in the Thread Network Data. If they match, the BR
recognizes another BR on the same mesh and backs off (does not re-advertise, does not act as
default router, does not proxy).

So the question isn't whether multi-BR loops by default. It's what in the HA
container breaks that peer-detection / prefix-coordination path. The answer is the broad
`fc00::/7` catch-all, which defeats the coordination because the mesh can conclude a too-broad
prefix already provides ULA reachability.

---

## 4. The stock upstream blast radius

The current upstream HA OTBR (`otbr-agent/run` and `otbr-agent-configure.sh` on the fork's
`master`, which tracks upstream) has:
- No route guard (no deletion of RA-learned OMR routes or covering `/48` from the backbone).
- No nftables hardening (stock uses `ip6tables` FORWARD chains only).
- No OMR prefix pinning.
- Unconditional `trel://backbone`.

Consequence: a single stock BR anywhere on the same L2 re-introduces the loop for everyone,
because it re-installs `fc00::/7` locally and re-advertises it into Network Data for the other BRs
to honor.

---

## 5. The two-layer fix

Two independent, complementary layers:

### Layer 1: stop the kernel route injection (local hardening, "at the symptom")

`OPENTHREAD_POSIX_CONFIG_INSTALL_EXTERNAL_ROUTES_ENABLE=0` in `openthread-core-ha-config-posix.h`
(the upstream openthread#13562 mechanism, replacing the earlier broad-ULA-route patch) stops the
POSIX platform from installing `fc00::/7` / `::/0` external routes into the host kernel, while
still installing the real OMR prefix. It is scoped to external routes, and it stops the BR from
stealing the entire ULA space toward wpan0.

### Layer 2: stop advertising the broad `/7` at the protocol layer (the actual fix)

`0006` routing-manager corrections:
- `kUlaPrefix` changed from `/7` to `/64` (`RoutingManager::RoutePublisher::kUlaPrefix`). This
  is the core protocol-layer change and the primary fix. Combined with the reworked
  `NetworkDataContainsUlaRoute()` (upstream now uses `IsCoveredBy()`), only a stable /64 OMR route
  counts as "the ULA route", so the mesh no longer thinks a `/7` is sufficient.
- `kPublishUla` now publishes `GetOmrPrefix()` (the real /64) instead of `GetUlaPrefix()`.
- Blocks publishing the default route `::/0`.

**Why the `/64` matters:** `kUlaPrefix` is used in two places:
1. `RoutePublisher::DeterminePrefixFor(kPublishUla)` — overridden by the patch to use
   `GetOmrPrefix()`, so `/64` here is defensive for that path.
2. `RoutingManager::NetworkDataContainsUlaRoute()` (line ~650), which still calls
   `RoutePublisher::GetUlaPrefix().ContainsPrefix(...)`. With `/7` it matches any `fd::`/`fc::`
   route as "ULA coverage" and lets the mesh conclude it already has ULA reachability from a
   too-broad prefix. Changing to `/64` makes this peer-detection sanity check meaningful on a
   multi-VLAN site, so BRs back off correctly and agree that a stable /64 OMR is "the ULA route."

### The two layers are complementary, not interchangeable

- Disabling installation (Layer 1, config header) is local hardening at the symptom.
- Not advertising (Layer 2, `0006`) is the protocol fix.

If only Layer 1 is done, OTBR still advertises `fc00::/7` in Network Data; other BRs on the mesh
that did not receive the patch will still honor it and install it. The loop only dies
network-wide if the advertisement is also tightened. Layer 2 is the actual protocol fix; Layer 1
is complementary local hardening. The PR should be framed this way, because maintainers will probe
exactly this distinction.

---

## 6. Mixed-firmware risk (highest-priority operational check)

Are all 6 BRs running the patched build? If any one of them is stock upstream (or an older
ts-otbr), that BR still installs `/7` and re-advertises it, keeping the loop alive for the whole
mesh no matter how clean the other 5 are. Mixed firmware is the most likely reason a fix
that works in a lab "doesn't fully fix" the office. Verify this first.

---

## 7. Border router count guidance

For this topology:
- Coverage is served by the 802.15.4 radios being physically distributed (each BR adds radio
  reach across the floor).
- Bandwidth is served by aggregate backbone egress.

6 distributed BRs is a sound baseline. The cost is coordination: every extra same-L2 BR adds
default-route/on-link advertisement and multicast duplication. Note that `leader_weight`
configures Thread leader election, a separate axis from border-routing default-router election.
If the OMR /64 coordination is solid, 6 is healthy; going much higher without a reason increases
peer-detection and multicast-dup overhead on the same segment.

---

## 8. Cross-BR prefix consistency requirement

With a deterministic OMR prefix (a hash of the Thread network name, or a user-pinned
`br omrconfig custom`) plus `GetOmrPrefix()` publication, all BRs
on a shared mesh must use the same OMR /64. If two BRs pin different /64s, the broad-prefix
loop is replaced by a prefix-disagreement problem. Requiring a consistent OMR prefix across all BRs
on a shared mesh must be documented in the PR.

---

## 9. Recommended verification / next steps

1. Confirm all 6 BRs run the patched build (no mixed firmware).
2. Validate on the live site with `ip -6 route` (confirm no `fc00::/7 dev wpan0`) and packet
   capture showing no circulation between BRs.
3. Verify that the nftables firewall is active and blocking TREL/ND/mDNS at the BR boundary
   (`nft list table ip6 otbr`).
4. Confirm all BRs advertise the same OMR /64 in their RAs on the backbone.
