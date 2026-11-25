# ZITADEL: ReadyStack build kit

The offline build kit for the Docker image `readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [v4.20.5-CE-ubuntu24.04-r1](https://github.com/readystack-dev/zitadel/releases/tag/v4.20.5-CE-ubuntu24.04-r1)
- Image: [`docker.io/readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1`](https://hub.docker.com/r/readystack/zitadel/tags), manifest digest `sha256:9e37b8a0a42b9609fe2f0b440e615099d4de59c72afad8f32cee9b97c3e53a92`
- Product page: https://readystack.dev/products/zitadel
- Source and build recipe: https://readystack.dev/products/zitadel/recipe
- Build trail: https://readystack.dev/products/zitadel/trail/v4.20.5-CE-ubuntu24.04-r1
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=zitadel

## The image

Single container, single static Go binary (CGO-free), foreground process — a cloud-native Identity & Access Management (IAM) / OIDC + OAuth2 + SAML + OpenID provider. REQUIRES an EXTERNAL PostgreSQL database the customer provisions and points the container at via ZITADEL_DATABASE_POSTGRES_* env vars — there is NO embedded/SQLite database. zitadel creates and migrates its own schema (event-sourced) in that postgres on first start. NOT a docker-compose-only or Kubernetes-only product, but it is NOT self-contained: postgres is a hard external dependency.

## Who uses ZITADEL and why

Developers building SaaS and business-to-business applications who need login, single sign-on and multi-tenancy.

ZITADEL is an open-source identity and access management platform with single sign-on over OpenID Connect and SAML, multi-factor login and passkeys, multi-tenancy, an audit trail of all events, and APIs.

A typical use: A software company sells its application to other businesses, each wanting its own branding and users. In ZITADEL each customer is an organisation with its own branded login and self-service user management, and the application signs everyone in through OpenID Connect.

From the upstream project's own description: https://github.com/zitadel/zitadel, https://zitadel.com/docs.

## This release

- Docker Scout policy grade at release: **A** (94%), graded 2026-11-23 with `docker scout policy` (CLI 1.26.0, docker-default configuration).
  - Docker Scout counts 7 packages with copyleft licences (GPL, LGPL, MPL), all of them operating-system packages (it counts only packages whose licence it can read; the SBOM lists every component).
- Signed with ReadyStack's release key (fingerprint `04daa92344a52dbc`): https://readystack.dev/keys/cosign.pub.
- Runs as a non-root user (`zitadel`).
- Attestations on the image: an SPDX SBOM and SLSA provenance v1.
- Rebuilt from this kit with network egress blocked on 2026-11-23; the rebuilt image digest is the published one.
- Base: Ubuntu 24.04.

The current grade, measured again every day, is on https://readystack.dev/products/zitadel.

ZITADEL is distributed under its upstream licence (AGPL-3.0-only); the kit contains upstream's source under that licence, and each vendored component under its own.

## Download

From the [v4.20.5-CE-ubuntu24.04-r1 release](https://github.com/readystack-dev/zitadel/releases/tag/v4.20.5-CE-ubuntu24.04-r1): `ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.tar.gz` (928.8 MB), SHA-256 `562e669d1000b22387755611f622419643a0989c9ec4db9044e4a3fce7056715`.

```sh
sha256sum --check --ignore-missing SHA256SUMS
```

## Verify and rebuild

The rebuild statement is signed with the ReadyStack release key. Check the signature before you rely on it:

```sh
cosign verify-blob --key https://readystack.dev/keys/cosign.pub \
  --bundle ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json.sigstore ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json
```

Unpack with `-p` so file modes are kept, then follow the kit's own README.md and docs/REBUILD.md:

```sh
tar -xpzf ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.tar.gz
cd v4.20.5-CE-ubuntu24.04-r1
less README.md docs/REBUILD.md
```

The build trail (`ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.trail.json`, signed the same way, and its Markdown copy) records how this release was built and checked.

## This repository

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/zitadel/recipe. The complete kit is the release download. Each release is a tag here.

— ReadyStack · https://readystack.dev
