# Lab upgrade transition contracts

These lab contracts describe unqualified umbrella upgrade candidates.
Resolve 1.0.4 and 1.1.0 through their pinned released manifests.
Version 1.0.1 is a legacy baseline without an umbrella manifest.
Keep released manifests and original inventories immutable.
Keep historical stack-only evidence bound to its original identities.
Do not reuse its qualification for a different manifest selection.

Validate from the repository root:

```sh
go -C tools/ncp-local-cluster/upgrade-lab test -race ./...
go -C tools/ncp-local-cluster/upgrade-lab vet ./...
git diff --check
```

Keep reports public-safe. Store credentials, raw output and backups outside the repository.
Qualification requires runtime evidence for the exact artifacts, configuration and topology.
