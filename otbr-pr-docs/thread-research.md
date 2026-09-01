# OpenThread Border Router Add-on: Routing & Firewall Architecture

Companion technical note for the OpenThread Border Router add-on PR.

## Provenance

This is not speculative work. It was driven by, and validated against, a large
live production deployment: a single-floor commercial office of roughly
35,000 sq ft running 450+ Thread devices across 6 border routers and two
switching racks. The fault this change fixes was first observed there at real
scale, and the solution has been running and exercised there since. The changes
below are the ones that survived contact with that network.

This document covers the routing-layer fixes, the nftables firewall, and the
hardening services the change introduces. It only covers what the PR touches and
avoids repeating the deep dives in the accompanying notes:

- Uplink theory (`uplink-theory-fc00-route.md`): the `fc00::/7` border-router
  loop on same-L2 multi-BR Thread networks.
- Multicast forwarding (`MULTICAST_FORWARDING.md`): the scope-gated multicast
  policy.

---

## 1. Overview

The stock Home Assistant OTBR add-on installs a broad `fc00::/7` ULA catch-all
route and applies only minimal `ip6tables` forwarding. On a multi-border-router
network sharing one L2 broadcast domain, that lets a BR hijack the entire ULA
space and silently drop cross-boundary multicast. The change here:

1. makes the BR's ULA/OMR prefix deterministic across restarts,
2. stops the broad `fc00::/7` route from being installed,
3. tightens Routing Manager prefix handling,
4. replaces the firewall with a spec-aware nftables table,
5. adds hardening services around the Thread interface (`wpan0`).

## 2. Deterministic ULA / OMR prefix

Root-cause analysis (see the uplink theory) points at prefix churn: when a BR
restarts and generates a fresh random ULA prefix, Thread partition children can
be orphaned and the BR reaches for the `fc00::/7` catch-all.

Config surface (additions to `config.yaml`, `DOCS.md`):

| Option | Type | Default | Purpose |
|---|---|---|---|
| `custom_omr_prefix` | `str?` | `""` | Pin a stable OMR prefix across restarts |
| `custom_omr_priority` | `list(high\|med\|low)?` | `"med"` | RIO/route preference for the OMR prefix |
| `leader_weight` | `int` | `72` | Influence which BR is elected Thread Leader |

Default derivation:

- When `custom_omr_prefix` is empty, the add-on hashes the Thread network name
  into a ULA `/64` and applies it via `ot-ctl br omrconfig custom`, so every
  border router on the same mesh converges on the same OMR prefix automatically
  (Apple border routers behave the same way). `custom_omr_prefix` remains the
  manual override.

A stable OMR prefix removes the orphaned-partition trigger: Thread devices no
longer strand on stale addresses, and the broad ULA fallback route is no longer
needed.

## 3. Stopping the `fc00::/7` route

- External routes are not installed into the host kernel: the project config
  header sets `OPENTHREAD_POSIX_CONFIG_INSTALL_EXTERNAL_ROUTES_ENABLE=0` (the
  upstream openthread#13562 mechanism), so `fc00::/7` and `::/0` from Thread
  Network Data never reach the kernel route table.
- `0006`: Routing Manager corrections: exact `/64` ULA-reachability matching,
  `kUlaPrefix` tightened from `/7` to the OMR `/64`, publish the actual OMR
  prefix instead of the broad one, and a guard against publishing `::/0`.

Together these remove the catch-all while keeping the specific `/64` the mesh
actually uses. (Full loop analysis: `uplink-theory-fc00-route.md`.)

## 4. nftables firewall

The add-on adopts the upstream `#3325` in-process nftables backend for unicast
ingress and NAT44: built with `-DOTBR_NFTABLES=ON`, otbr-agent owns a single
`inet otbr` table whose `forward_ingress` chain filters unicast into the Thread
interface (its sets are produced from Thread Network Data) and whose nat chains
masquerade IPv4. The add-on's `ip6 otbr` table below supplies what the backend
does not: host input/output protection, scope-gated multicast (the mDNS
containment), TREL isolation, protocol drops, and the Docker `DOCKER-USER`
hole. The add-on forward chains deliberately end in `return` for unicast so the
in-process backend filters it.

The stock `ip6tables` setup (minimal ingress, single ACCEPT egress rule) is
replaced by an nftables table `ip6 otbr` with seven chains:

| Chain | Hook | Policy | Purpose |
|---|---|---|---|
| `forward` | `forward` | `accept` | dispatcher, branches by interface |
| `input` | `input` | `accept` | host-bound control-plane filtering |
| `output` | `output` | `accept` | host-originated filtering |
| `otbr_to_thread` | jump | `drop` | dispatches backbone→Thread |
| `from_backbone_to_thread` | jump | `drop` | ingress, default-deny |
| `otbr_from_thread` | jump | `drop` | dispatches Thread→backbone |
| `from_thread_to_backbone` | jump | `drop` | egress, default-deny |

Highlights vs stock:

- Bidirectional default-deny forwarding, with drop logging; stock egress was a
  single `ACCEPT`.
- Host input/output protection the stock add-on lacks entirely: TREL isolated
  to the backbone, MLE/TMF allowed to the host, RAs from Thread dropped,
  unicast SRP allowed while multicast mDNS/SSDP is dropped.
- Scope-gated multicast replacing the blanket multicast drop;
  `MULTICAST_FORWARDING.md` is the authoritative write-up.
- ipset-to-nftables set sync bridging OTBR's ipset API to nftables sets (see
  `otbr-ipset-sync` below).
- Docker `DOCKER-USER` integration so forwarding works in containerized
  operation.

## 5. Hardening services

Three s6 services are added:

- `otbr-route-guard` (longrun): removes RA-learned and backbone-bound routes to
  the OMR prefix and its covering `/48`, closing the loop where mesh-destined
  traffic exits the backbone instead of `wpan0`.
- `otbr-ipset-sync` (longrun): continuous ipset-to-nftables set synchronizer.
- `otbr-wpan-sysctl` (oneshot): IPv6 sysctl hardening on `wpan0`
  (`accept_ra=0`, `forwarding=1`, ...).

## 6. Build & configuration surface

- Both builder stages build with `-DOTBR_NFTABLES=ON` (the in-process backend,
  via libnftnl/libmnl) against the ot-br-posix main tip. The patch set is a
  single `0006` routing-manager correction applied to both stages; `0001`
  (SO_REUSEADDR) and `0002` (NAT64 IPv4-options hardening) proved to be
  already upstream on the rebased base, and the speculative ULA-prefix /
  broad-ULA-route patches were removed.
- `OTBR_DHCP6_PD=ON` with `_CLIENT=openthread` enables Thread 1.4 DHCPv6 Prefix
  Delegation.
- Both stages build `-DOT_THREAD_VERSION=1.4`; the header enables Thread 1.4
  features Multi-AIL detection and peer-BR tracking (`TRACK_PEER_BR_INFO` +
  heap), alongside the broad-ULA-route flag.
- New config options: `custom_omr_prefix`, `custom_omr_priority`,
  `leader_weight` (see §2), with the existing `nat64` / `beta` toggles retained.

## 7. Scope of this submission

Deliberately left out of this change:

- NAT64. NAT64 remains available via the existing config toggle; NAT44
  masquerade is provided by the in-process backend when enabled, or by the
  add-on's nftables NAT44 table in legacy mode.
- Thread-version switching. The `beta` toggle no longer switches between Thread
  1.3/1.4 binaries for this change; both stages are built as Thread 1.4 and the
  toggle is retained for compatibility.

## Summary

The change removes the `fc00::/7` catch-all and makes the OMR prefix
deterministic (patches + config options), hardens packet forwarding with a
spec-aware nftables firewall including scope-gated multicast, and adds three
small hardening services around the Thread interface. Together those keep a
multi-BR Thread network stable without hijacking the ULA space.
