# Lab upgrade transition contracts

These contracts describe exact upgrade candidates, not published support.
They are lab inputs and reports, not required deployment files.
Route versions identify Self-Managed stack tags. Keep original release assets
immutable. Record peer stack versions separately. Read each cited edition's
matrix separately; its selected stacks do not redefine route endpoints.
Select each endpoint's peers from its recorded matrix and retain the peer
matrix edition in the artifact lock. Preserve mixed-fleet candidate states.

Validate from the repository root:

```sh
go test -C tools/ncp-local-cluster/upgrade-lab ./...
git diff --check
```

Keep reports public-safe. Store private endpoints, credentials, raw command
output and cluster backups outside the repository. Qualification requires
runtime evidence for the exact artifacts and topology.
