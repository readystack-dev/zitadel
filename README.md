# ZITADEL: ReadyStack build kit

The offline build kit for the Docker image `readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1`. It holds what the image is built from (upstream source, base images, toolchain, pinned dependencies) and the documents, so the image can be rebuilt with no network access (`docker build --network=none`).

- Release: [v4.20.5-CE-ubuntu24.04-r1](https://github.com/readystack-dev/zitadel/releases/tag/v4.20.5-CE-ubuntu24.04-r1)
- Image: [`docker.io/readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1`](https://hub.docker.com/r/readystack/zitadel/tags), manifest digest `sha256:9e37b8a0a42b9609fe2f0b440e615099d4de59c72afad8f32cee9b97c3e53a92`
- Product page: https://readystack.dev/products/zitadel
- Defects: this repository's Issues (defects recorded from 25 November 2026 on) and https://readystack.dev/defects.html?product=zitadel

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
