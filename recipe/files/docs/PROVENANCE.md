# Provenance — ZITADEL (`v4.20.5-CE-ubuntu24.04-r1`)

Every item below is copied from a record in this archive; the record is named in brackets.

## Source

- Upstream repository: https://github.com/zitadel/zitadel
- Revision built: `v4.20.5` (commit `59827a8ec6dd0c23acbba5d0ebdf41fdc857d66c`)
- Source tree: `1a42e40f735f7105c88afa725f146f705ff420e7138c8a29711d1c73a397fbb4` over 9649 files [`docs/provenance/SOURCE_TREE_HASH.json`]
- Community Edition only: enterprise code is removed or refused before the build (CE audit at acquire).

## Build

- Method: `source-rebuild-go`; base image `scratch + a chiselled Ubuntu 24.04 runtime (vendored/chisel/slices.txt, packages.tsv)`
- Compiled with `--network=none` from vendored source, dependencies and base images; BuildKit pinned to `moby/buildkit:v0.31.2` (shipped in `toolchain/`).
- SOURCE_DATE_EPOCH: `1795404451` [`SOURCE_DATE_EPOCH.txt`]
- Frozen inputs: [`docs/provenance/FREEZE_MANIFEST.json`], build recipe: [`docs/provenance/BUILD_RECIPE.json`].

## Output

- Published image: `readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1` — index digest `sha256:44ab17cfdfc0574878687d1720f22a28ff80f1c277d91f3b2be33d76f336a847` [`docs/provenance/LOCKED_DIGEST.txt`]
- linux/amd64 image digest `sha256:9e37b8a0a42b9609fe2f0b440e615099d4de59c72afad8f32cee9b97c3e53a92` — reproduced from this archive before publishing [`docs/provenance/REPRO_VERIFICATION.json`].

## Attestations and signature

- SBOM + SLSA provenance attached to the image: attached: an SPDX SBOM and SLSA v1 provenance [`docs/provenance/SCOUT_VERDICT.json`]
- cosign signature by the ReadyStack release key: verified before publishing. Check it: `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1`

## Pinned inputs, and why

- 43 pinned inputs, each with where it came from, why this one, how it was checked and when it was decided: `docs/PINS.md` [`docs/provenance/PINS.json`] (upstream source 2, base and build images 3, image digests 2, language runtimes and toolchains 1, dependency versions readystack sets 11, pins in the kit's dockerfiles 14, readystack's build engine 5, dependencies upstream chose 2, services the release checks run beside 3).

## Build trail

- How this release passed through the ReadyStack harness, record by record (every chain, drive, stage, review round, defect and check, each naming the record it is copied from): `ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.trail.json`, published beside this archive and signed with the release key (`ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.trail.json.sigstore`), and readable at https://readystack.dev/products/zitadel/trail/v4.20.5-CE-ubuntu24.04-r1.

