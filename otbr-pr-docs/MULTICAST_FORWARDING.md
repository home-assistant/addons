# Border Router Multicast Forwarding: Scope-Gated Policy

Status: part of the Open Home Foundation OTBR add-on fork submission
Applies to: `rootfs/etc/s6-overlay/s6-rc.d/otbr-agent/run` (nftables table `ip6 otbr`)

## Why this exists

The OpenThread Border Router is a strict two-sided forwarder between the Thread
radio interface (`wpan0`) and the infrastructure/backbone interface (`-B`).
Thread being an L2 mesh doesn't remove directionality. This change fixes the
multicast part of that forwarding model so the BR behaves like a
spec-conformant Thread 1.3+ border router, and so multicast can't loop.

Two neighboring realities make this necessary, and they compound in any
multi-BR deployment. This document centers on the second. The first is analyzed
in `uplink-theory-fc00-route.md`.

### Reality 1: the routing loop (the `fc00::/7` catch-all)

A broad ULA route (`fc00::/7`) that a BR installs in a multi-BR, shared-L2
network hijacks the entire ULA space and loops traffic. That is a routing-level
failure, fixed by the deterministic-prefix and route-correction patches. It
isn't the subject of this doc, but it sets the stage. At this deployment's
scale, one BR's behavior becomes every BR's problem.

### Reality 2: the mDNS leak loop

Current OTBR releases let the OTBR agent leak its mDNS advertisements out of
both interfaces, the Thread radio (`wpan0`) and the backbone. On a network with
more than one border router on the same L2, that isn't harmless noise. An
advertisement that leaks out one BR's `wpan0` crosses the Thread mesh and
re-emerges at a second BR, which leaks it out its own backbone, and from there
it is back where it started. The result is a forwarding loop of the BR's own
mDNS.

This isn't hypothetical under load. It is what happens the moment a second
border router joins a shared fabric. The multicast policies below are built
around stopping it.

## What this replaces

Stock Home Assistant OTBR ships an `ip6tables` firewall. On the forward path it
drops unicast into the Thread interface and accepts everything out of it:

    ip6tables -A "${otbr_forward_ingress_chain}" -m pkttype --pkt-type unicast -j DROP
    ip6tables -A "${otbr_forward_egress_chain}" -j ACCEPT

That egress line is the crux. It forwards multicast out of the Thread interface
to the backbone with no scope check at all. On a multi-BR network that is
exactly the gap the mDNS leak loop (Reality 2) falls through: a stock BR passes
discovery multicast across the boundary unexamined, it reaches the other border
routers, and it comes back. Nothing filters it.

The nftables table here is new to the HA add-on. It replaces that posture with
controlled, scope-gated forwarding. There are two ways to get this wrong, and
the design sidesteps both:

1. Forward everything, like stock. That leaves the leak open and exposes the
   mesh to whatever multicast shows up at the boundary.
2. Drop all multicast, a blunt hardening pass. That protects the mesh but
   breaks the Thread multicast contract: Thread 1.3+ border routers forward
   scopes above realm-local via Multicast Listener Registration (MLR) and the
   Primary Backbone Router (PBBR) using MLDv2 on the external interface. It
   also breaks legitimate multicast Matter and Thread devices rely on,
   including Matter fabric group operations (site-local `ff35::`).

The scope gate threads the needle: forward admin-local and above, drop
link-local and realm-local at the boundary. Storm and leak risk stay where they
belong, and the multicast the network depends on keeps working.

## The spec mechanism we now permit

Per the OpenThread BR IPv6 multicast codelab and the Espressif ESP Thread BR
multicast-forwarding documentation:

- A Thread device registers a multicast address with the PBBR via MLR (a CoAP
  message over TMF, UDP 61631) when the group scope is larger than realm-local.
- The PBBR uses MLDv2 on its external interface to join those groups on behalf
  of the Thread network.
- The PBBR forwards multicast into the Thread network only if the destination
  group is subscribed to by at least one Thread device.
- Per the ESP Thread BR doc, to forward packets between Thread and the Wi-Fi
  network the multicast group scope has to be at least admin-local (`ff04`);
  link-local and realm-local multicast are not forwarded.

The key insight: per-group subscription is enforced by the kernel multicast
routing (MLR + MLDv2), so the firewall doesn't need to hand-maintain group
lists. It only needs to gate by scope so mesh-local scopes (which by definition
never cross a router) can't leak onto the backbone, and can't loop to another
BR.

## What the firewall now does

In both forward chains (`from_backbone_to_thread` and
`from_thread_to_backbone`), the blanket multicast drop is replaced with a
three-rule scope gate:

    ip6 daddr ff00::/8 meta pkttype { broadcast } counter drop   # no broadcast
    ip6 daddr @mcast-fwd-scope counter accept                     # admin/global scope
    ip6 daddr ff00::/8 counter drop                               # mesh-local scope

where `@mcast-fwd-scope` is a named set containing the multicast scope prefixes
admin-local (`ff04::/16`) and above:

    set mcast-fwd-scope {
        type ipv6_addr
        flags interval
        auto-merge
        elements = { ff04::/16, ff05::/16, ff06::/16, ff07::/16,
                     ff08::/16, ff09::/16, ff0a::/16, ff0b::/16,
                     ff0c::/16, ff0d::/16, ff0e::/16, ff0f::/16 }
    }

Effect:

- admin-local and above (`ff04::/16` ... `ff0e::/16`): forwarded across the
  boundary. This includes Matter fabric group multicast, which uses site-local
  `ff35::` (scope 5, captured by `ff05::/16`).
- link-local (`ff02::/16`) and realm-local (`ff03::/16`): still dropped at the
  boundary. Correct by IPv6 routing rules; these scopes never cross a router.
- broadcast: still dropped (IPv6 has no broadcast; this is a safety).

Note on the in-process backend: with `-DOTBR_NFTABLES=ON` (upstream #3325,
adopted by this PR), otbr-agent owns unicast ingress into `wpan0` and NAT44 in
its own `inet otbr` table. The scope gate above is the add-on layer: it runs
at the same forward hook and deliberately ends in `return` for unicast, so the
backend still filters it. Multicast containment is this layer's job; unicast
ingress is the backend's.

### How this stops the mDNS loop

mDNS lives at link-local scope, `ff02::fb`, inside the `ff02::/16` the scope
gate drops at the boundary in both directions. That single rule closes the loop
from Reality 2. Because link-local multicast can't cross a BR boundary in
either direction, an mDNS advertisement leaked by one BR's agent onto its
`wpan0` can't travel across the mesh to a second BR and out its backbone. The
BR's own advertisements stay contained to the interface they were emitted on.
This is where the storm and leak risk lives, so the hardening intent of a
drop-everything approach is preserved where it matters, instead of breaking the
admin-local multicast the network depends on.

## What is NOT changed

- The mesh's own control plane (MLE 19788, TMF 61631) is unaffected.
- Unicast OMR forwarding and the ingress/egress allow-list ipsets are
  unaffected.
- MLD signaling on the backbone (the PBBR's MLDv2 joins) remains permitted on
  the external interface so per-group subscription forwarding keeps working.
- SRP service registration (the control plane behind service discovery) is
  unaffected; only the leaking of link-local multicast advertisements across
  the boundary is stopped.
- The strict default-deny posture of both forward chains is preserved: any
  packet that is not explicitly accepted is still dropped and logged.

## Verification / test narrative to include in the PR

1. On the target site (a single-L2, multi-BR Thread deployment), confirm the
   agent's mDNS advertisements no longer re-emerge at a second BR after the
   scope gate is in place.
2. Confirm the old blanket-drop behavior reproduced missing Matter group
   operations, and the new rules restore them.
3. `ping -I <backbone> -t 64 ff04::123` with a Thread device joined to
   `ff04::123` (Espressif codelab procedure) to prove admin-local multicast is
   forwarded.
4. Confirm `ff02::`/`ff03::` multicast is still not forwarded (storm protection
   intact, mDNS leak loop closed) via `tcpdump` on the backbone with a Thread
   device emitting link-local multicast.
5. Confirm no routing loop and no regression in Matter operational discovery,
   which does not depend on mesh multicast at all (SRP + Advertising Proxy).

## PR framing

This change ships with the routing-loop fix and the architecture overview
because, in this deployment, the routing loop and the mDNS leak loop are two
sides of the same multi-BR problem. Both are failures of one BR's emissions
leaking across a shared fabric to another. Presenting them together makes clear
that the solution is a coherent multicast-and-routing boundary, not an isolated
tweak.
