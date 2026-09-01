# OpenThread Border Router PR — Documentation Pack

Organized companion documentation for the **OpenThread Border Router** add-on
PR (branch `otbr-pre-pr-sync`, pinned OMR prefix + `fc00::/7` routing fix).

All files here are ready to attach to, or reference in, the PR.

## Index

| File | What it is | Role |
|---|---|---|
| `uplink-theory-fc00-route.md` | The `fc00::/7` border-router loop on same-L2 multi-BR Thread networks | Primary technical attachment (root-cause analysis) |
| `MULTICAST_FORWARDING.md` | Scope-gated multicast forwarding policy (Thread 1.3+) | Firewall/multicast deep-dive |
| `thread-research.md` | Routing & firewall architecture companion (concise) | Architectural overview of the change |
| `DOCS.md` | Add-on usage / configuration documentation | User-facing docs (ship in-repo) |
| `CHANGELOG.md` | Version changelog for the add-on | Ship in-repo |

## Suggested reading order

1. `uplink-theory-fc00-route.md` — why the fix exists
2. `thread-research.md` — what the change does
3. `MULTICAST_FORWARDING.md` — the multicast piece in depth

`DOCS.md` / `CHANGELOG.md` live in the add-on itself and are mirrored here for
convenience when assembling the submission.

---

*Note: thresholds (`upgrade_threshold` / `downgrade_threshold`) were intentionally
removed from this submission.*
