# OpenThread Border Router: multi-BR routing, mDNS containment, and firewall fixes

**Branch:** `otbr-routing-corrections` (from `master`)
**Add-on:** `openthread_border_router`

## What this is for

I run this add-on on a live commercial deployment: a single-floor office around
35,000 sq ft with 450+ Thread devices, six border routers, and two switching
racks on one shared L2. At that size, whatever breaks breaks loudly, and it
keeps breaking until you fix it. Neither problem this PR fixes was something I
read about. Both happened to me, at scale, and both are why the changes here
exist.

## Problems

### Routing loop — external routes (`fc00::/7`)

On a multi-BR network sharing one broadcast domain, a border router can install
broad external routes (`fc00::/7`, `::/0`) from Thread Network Data into the
host kernel. That swallows the whole ULA space. Devices end up stranded on stale
prefixes, and the mesh starts routing in circles. The detail is in
`uplink-theory-fc00-route.md`. Upstream agreed (openthread#13562) and disabled
external-route installation by default; this PR ships the same `0` via the
project config header on top of a rebased upstream build.

### mDNS leak loop

Current OTBR releases let the agent's own mDNS advertisements leak out of both
interfaces, `wpan0` and the backbone. On a shared fabric with a second border
router, that wraps around. An advertisement leaves one BR's `wpan0`, crosses the
mesh, shows up at the next BR, and comes back out its backbone. The network ends
up forwarding its own discovery traffic in a loop. Details are in
`MULTICAST_FORWARDING.md`.

## What changed

- Rebased onto the ot-br-posix main tip and trimmed the patch set to one
  routing-manager improvement (`0006`). `SO_REUSEADDR` and the NAT64 IPv4-options
  hardening turned out to be already upstream; the speculative ULA-prefix and
  broad-ULA-route patches were removed.
- Deterministic OMR prefix. `custom_omr_prefix` remains the manual override;
  when it is empty the add-on derives a ULA `/64` by hashing the Thread network
  name, so every border router on a mesh converges on the same prefix
  automatically (Apple border routers behave the same way) without per-BR
  configuration.
- Firewall. Adopted the upstream `#3325` opt-in in-process nftables backend for
  unicast ingress and NAT44, and kept the add-on layer that upstream does not
  provide: scope-gated multicast (the mDNS containment), host input/output
  protection, TREL isolation, the Docker `DOCKER-USER` hole, and protocol drops.
  The `firewall` toggle now slices the add-on layer.
- Hardening services. `otbr-route-guard` and `otbr-wpan-sysctl` stay;
  `otbr-ipset-sync` no-ops under the in-process backend (the agent produces its
  ingress sets itself).
- Thread 1.4. DHCPv6 Prefix Delegation, Multi-AIL detection, peer-BR tracking.

## Tested where it lives

The network that exposed these bugs is the same one validating the fix. Both
loops reproduced at that scale, and both are gone there. The image also builds
cleanly from a fresh host. Validating against 450+ nodes across six border
routers is a proof most OTBR deployments never get to run.

## Commits

- `70457f8` derive deterministic OMR prefix from Thread network name
- `ef7dc40` wire runtime for the in-process nftables backend (#3325)
- `14d8fa1` enable in-process nftables backend at build time
- `8e4dc74` rebase onto ot-br-posix #3325 and trim the patch set to one

## Companion documentation

- `uplink-theory-fc00-route.md` — analysis of the fc00::/7 border-router loop
- `MULTICAST_FORWARDING.md` — multicast policy and the mDNS leak loop
- `thread-research.md` — routing & firewall architecture overview
