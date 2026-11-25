# ZITADEL v4.20.5 — ReadyStack release `v4.20.5-CE-ubuntu24.04-r1`

Generated 2026-11-23 from this release's build records and strategy. Statements that come from a single record name it in brackets; the others come from this release's strategy and build log.

## Release

- **Image:** `readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1` (linux/amd64). Index digest `sha256:44ab17cfdfc0574878687d1720f22a28ff80f1c277d91f3b2be33d76f336a847` [`docs/provenance/LOCKED_DIGEST.txt`].
- **Image manifest digest:** `sha256:9e37b8a0a42b9609fe2f0b440e615099d4de59c72afad8f32cee9b97c3e53a92` [`TARGET_DIGEST.txt`].
- **Upstream:** ZITADEL v4.20.5 built from source at `v4.20.5` of https://github.com/zitadel/zitadel — upstream notes: https://github.com/zitadel/zitadel/releases/tag/v4.20.5 [`docs/provenance/BUILD_RECIPE.json`].
- **Base image:** none (`FROM scratch`): a chiselled Ubuntu 24.04 runtime, the files Canonical's chisel cut from Ubuntu's own packages (`vendored/chisel/slices.txt`, `vendored/chisel/packages.tsv`); runtime user `zitadel`.
- **Build:** `source-rebuild-go`, compiled offline with `--network=none`.
- **Supersedes:** ReadyStack release `v4.20.1-CE-ubuntu24.04-r1`.

## What changed in this release

- Upstream version v4.20.1 → v4.20.5.
- Minimum dependency versions ReadyStack enforces on top of upstream (raised only where upstream's own version was lower); shipped versions from the SBOM [`docs/sbom/SBOM.json`]:
  - `golang.org/x/crypto` at least `v0.56.0`: not raised, upstream already pins `v0.58.0` (shipped: `v0.58.0`)
  - `golang.org/x/net` raised from upstream's `v0.61.0` to at least `v0.62.0` (shipped: `v0.62.0`)
  - `golang.org/x/text` at least `v0.38.0`: not raised, upstream already pins `v0.43.0` (shipped: `v0.43.0`)
  - `golang.org/x/sys` at least `v0.46.0`: not raised, upstream already pins `v0.49.0` (shipped: `v0.49.0`)
  - `google.golang.org/grpc` at least `v1.83.2`: not raised, upstream already pins `v1.84.0` (shipped: `v1.84.0`)
  - `github.com/go-chi/chi/v5` at least `v5.3.2`: not raised, upstream already pins `v5.5.0` (shipped: `v5.5.0`)
  - `github.com/klauspost/compress` raised from upstream's `v1.19.1` to at least `v1.20.2` (shipped: `v1.20.2`)
  - `github.com/go-jose/go-jose/v4` at least `v4.1.6`: not raised, upstream already pins `v4.1.7` (shipped: `v4.1.7`)
- This release moves ZITADEL from 4.20.1, which the release this supersedes (v4.20.1-CE-ubuntu24.04-r1) packaged, to 4.20.5, the newest release of upstream's 4.20.x line, and rebuilds it on a slim base. 4.20.5 makes the login require the configured second factor before a user adds an authenticator; 4.20.2 to 4.20.4 are bug fixes and performance changes, among them PKCE by default for the Google, GitHub, GitLab and Azure AD identity providers. Changes: the image no longer starts from the full ubuntu:24.04 image. It is built FROM scratch with a chiselled Ubuntu 24.04 runtime: only the files that Canonical's chisel cut from a few Ubuntu packages (base-files, base-passwd, ca-certificates, tzdata, the dash shell, part of coreutils, and the libraries they need; the list is vendored/chisel/packages.tsv in the release archive). The image has a POSIX shell (/bin/sh) but no bash, curl, openssl, grep, ls or id, and its HEALTHCHECK runs /usr/local/bin/rs-probe, a small HTTP probe built from source in the kit, instead of curl. zitadel, the entrypoint (start-from-init still requires ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD), port 8080, the PostgreSQL settings, the masterkey file (readable by uid 999) and the runtime user (uid 999) are those of v4.20.1-CE-ubuntu24.04-r1: replace the container with this image against the same database and masterkey. Upstream's release notes list what changed: https://github.com/zitadel/zitadel/releases (v4.20.2 to v4.20.5)

## Security status at release (measured 2026-11-23)

- **Docker Scout:** 0 fixable critical/high vulnerabilities; runs as `zitadel` (non-root); SBOM + provenance attestations present (SPDX SBOM + SLSA v1) [`docs/provenance/SCOUT_VERDICT.json`].
- **OSV cross-check:** no fixable critical/high vulnerability beyond Docker Scout's findings.
- **Signature:** cosign signature verified by ReadyStack's release gate before publishing; check it yourself with `cosign verify --key https://readystack.dev/keys/cosign.pub readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1` (signatures are recorded in the public Sigstore transparency log).
- **ReadyStack release check at release:** passed (ReadyStack's own test, not a Docker Scout grade). Vulnerabilities are disclosed every day and the image never changes, so it is re-checked daily, beside Docker Scout's own dated grade, at https://readystack.dev/queue.
- **Before exposing this service:** The first administrator's password is yours to choose (ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD); the image refuses to create an instance without it.
- **Before exposing this service:** The masterkey encrypts secrets in the database: store it outside the container (--masterkeyFile) and never commit it.
- **Before exposing this service:** With --tlsMode disabled the container serves plain HTTP; in production terminate TLS in front of it (--tlsMode external) or give it certificates (--tlsMode enabled).
- **Before exposing this service:** ZITADEL writes a warning to its log for every notification it renders. Upstream includes the one-time code (password reset, email verification, initial password) in that warning; this image removes the code from the message, so reset codes are not written to the container log.

## Reproducibility

Rebuilds offline from this archive to the identical image digest `sha256:9e37b8a0a42b9609fe2f0b440e615099d4de59c72afad8f32cee9b97c3e53a92`: run `./BUILD_OFFLINE.sh`, then `./VERIFY_OFFLINE.sh` (add `--online` to confirm the Docker Hub tag holds the same digest). Before publishing, ReadyStack rebuilt the kit with `./BUILD_OFFLINE.sh` and compared the result with the published digest [`docs/provenance/REPRO_VERIFICATION.json`], then ran `./BUILD_OFFLINE.sh` and `./VERIFY_OFFLINE.sh` from this archive (without `--online`).

## Validation

- 3 of 3 use cases passed (4 authored, 3 kept in the suite; 1 not exercised, see below) against a container of this image started with `start-from-init --masterkey MasterkeyNeedsToHave32Characters --tlsMode disabled --externalDomain localhost --externalPort 8080` after the image name (the image has no default command) [`docs/validation/test-results.json`]. A container started the default way can answer differently.
- The cases are `GET /debug/healthz` (200), `GET /debug/ready` (200), `GET /debug/validate` (200); the suite checks nothing else.
- 1 further authored check was not exercised and is not counted above: it named a path that is not part of this product's API (listed under Not exercised in `docs/validation/FAILED_TESTS.md`).

## Known issues

- **low** (ReadyStack package): The image refuses to start without ZITADEL_FIRSTINSTANCE_ORG_HUMAN_PASSWORD, although ZITADEL uses it only to create the first instance [`RSD-zitadel-a8da0d3fce`] (carried from `v4.19.5-CE-ubuntu24.04-r1`, recorded there as `RSD-zitadel-5f600f13d4`)
- **low** (ReadyStack package): Docker Hub README: The sentence tells the customer to take 'passwords that only set up the first start' out of the env file after setup. [`RSD-zitadel-af3403e144`] (carried from `v4.20.0-CE-ubuntu24.04-r1`, recorded there as `RSD-zitadel-f3bfb84ebe`)

## Defects fixed

- 12 problems found before release and fixed before it shipped (12 by review); each is listed in `docs/defects/defects.json`.

## Verify this archive

```
sha256sum -c CHECKSUMS.sha256
./BUILD_OFFLINE.sh && ./VERIFY_OFFLINE.sh --online
cosign verify --key https://readystack.dev/keys/cosign.pub readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1
```

ReadyStack records every signature in the public Sigstore transparency log (Rekor), so the command needs no extra flags.

