[![ReadyStack](https://readystack.dev/logo.svg)](https://readystack.dev)

**Stable, Open-source Releases, Automated** · [readystack.dev](https://readystack.dev)

[![Docker Hub](https://img.shields.io/badge/Docker%20Hub-readystack%2Fzitadel-2496ED?logo=docker&logoColor=white)](https://hub.docker.com/r/readystack/zitadel) [![Docker pulls](https://img.shields.io/docker/pulls/readystack/zitadel)](https://hub.docker.com/r/readystack/zitadel) [![Grade at release](https://img.shields.io/badge/grade%20at%20release-A%20%2894%25%29-2ea44f)](https://readystack.dev/products/zitadel) [![Signed: cosign](https://img.shields.io/badge/signed-cosign-2ea44f)](https://readystack.dev/keys/cosign.pub) ![SBOM: SPDX](https://img.shields.io/badge/SBOM-SPDX-2ea44f) ![Provenance: SLSA v1](https://img.shields.io/badge/provenance-SLSA%20v1-2ea44f) ![Offline rebuild: verified](https://img.shields.io/badge/offline%20rebuild-verified-2ea44f)

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

`recipe/` holds the kit's recipe files (Dockerfiles, build scripts, pins) as published at https://readystack.dev/products/zitadel/recipe. The complete kit is the release download. Each release is a tag here. How to report a vulnerability: [SECURITY.md](SECURITY.md).

## About ReadyStack

**Stable, Open-source Releases, Automated.** ReadyStack releases popular open-source apps every week with every available critical and high security fix applied, plus full documentation, reference data, tests and a build recipe that recreates each release bit-for-bit. Each release is rebuilt from its pinned inputs with the network off, checked against its published digest, signed, and scanned and graded again every day. The images and build kits are free, and ReadyStack is soon to be a nonprofit.

[readystack.dev](https://readystack.dev) · [All products](https://readystack.dev/products.html) · [Build kits on GitHub](https://github.com/readystack-dev) · [Defect log](https://readystack.dev/defects.html) · contact@readystack.dev

— ReadyStack · https://readystack.dev
