# Verifying ZITADEL (`v4.20.5-CE-ubuntu24.04-r1`)

## Integrity of this archive

```
sha256sum -c CHECKSUMS.sha256
```

## Reproduce the image

See `docs/REBUILD.md`: `./BUILD_OFFLINE.sh && ./VERIFY_OFFLINE.sh --online`.

## Signature

```
cosign verify --key https://readystack.dev/keys/cosign.pub readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1
```

ReadyStack signs with its own key and records every signature in the public Sigstore transparency log (Rekor), so the command needs no extra flags. Releases signed before 2026-10-07 were re-signed with the current key that day.

## Signed attestations

At publish, ReadyStack attaches in-toto attestations to the image, signed with the same key and recorded in the transparency log: SLSA v1 provenance that ReadyStack writes from this archive's records (its assertion from recorded evidence, not a statement by the build platform), a SLSA Verification Summary Attestation of ReadyStack's release gate, and the image's SPDX SBOM. An SBOM too large for the transparency log is not attached as a signed attestation: it stays inside the image index, under the signed index digest. How each is written: https://github.com/ReadyStackFree/rebuild-bundle-spec/tree/v0.1.0/attestations.

```
cosign verify-attestation --key https://readystack.dev/keys/cosign.pub --type slsaprovenance1 readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1
cosign verify-attestation --key https://readystack.dev/keys/cosign.pub --type spdxjson readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1
cosign verify-attestation --key https://readystack.dev/keys/cosign.pub --type https://slsa.dev/verification_summary/v1 readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1
```

## Security check

At release: passed the ReadyStack release check (ReadyStack's own test, not a Docker Scout grade) — 0 fixable critical/high, runs as `zitadel` [`docs/provenance/SCOUT_VERDICT.json`]. The image never changes but new vulnerabilities are disclosed daily; today's result and Docker Scout's own dated grade are at https://readystack.dev/queue.

