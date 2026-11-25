# Rebuilding ZITADEL offline

This archive is the complete build kit for `readystack/zitadel:v4.20.5-CE-ubuntu24.04-r1`; it does not contain the image itself.

## Requirements

- linux/amd64 Docker with `buildx` 0.30 or later, plus `jq` and `tar` (VERIFY_OFFLINE.sh does not boot this image). BUILD_OFFLINE.sh needs no network access and builds with the network off; only `./VERIFY_OFFLINE.sh --online` contacts a registry (Docker Hub).
- Hardware: ReadyStack reproduced this image on a 8-CPU host with 23.5 GB of memory, in about 3.4 minutes. A host with less memory may fail the build with `cannot allocate memory`.

## Steps

```
tar -xpzf ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.tar.gz   # -p keeps every file's mode: modes are build input
cd v4.20.5-CE-ubuntu24.04-r1
./BUILD_OFFLINE.sh    # loads the pinned BuildKit from toolchain/, creates a fresh builder,
                      # builds --no-cache --network=none from vendored bases and sources,
                      # writes rebuilt.oci.tar + rebuilt.docker.tar
./VERIFY_OFFLINE.sh   # compares rebuilt.oci.tar's digest with the published one (boot check skipped: see below)
./VERIFY_OFFLINE.sh --online   # also confirms the Docker Hub tag holds that digest
```

A Dockerfile `COPY` carries file modes into the image. Unpacked without `-p`, a non-root user's umask changes them (664 becomes 644 under umask 022); `FILE_MODES.tsv` records each file's and directory's mode as packed, and BUILD_OFFLINE.sh puts back any that differ before it builds (`./BUILD_OFFLINE.sh --restore-modes` does only that).

VERIFY_OFFLINE.sh does not boot this image: this image needs pg (not part of this archive); boot it with your own services as the admin handbook describes.

Expected image digest: `sha256:9e37b8a0a42b9609fe2f0b440e615099d4de59c72afad8f32cee9b97c3e53a92` (recorded in `TARGET_DIGEST.txt`).

## The rebuild manifest (`rebuild.json`) and the verifier

This archive is a ReadyStack Rebuild Bundle (specification v0.1, draft, Apache-2.0: https://github.com/ReadyStackFree/rebuild-bundle-spec). `rebuild.json`, at the top of the archive, is its manifest:

- `subject.image_manifest_digest`: the linux/amd64 image the archive rebuilds, `sha256:9e37b8a0a42b9609fe2f0b440e615099d4de59c72afad8f32cee9b97c3e53a92`; `subject.name` is the release tag;
- `engine`: the BuildKit image the build runs in, loaded from `toolchain/buildkit.tar` (never pulled), named by its image ID;
- `inputs`: the Dockerfile, `SOURCE_DATE_EPOCH`, the mtime rule, and `tree_hash`, a hash over the path, mode and content of every file in the archive except `rebuild.json`, `CHECKSUMS.sha256` and `MANIFEST.txt`, so a changed, added or missing file is detected;
- `bases`: each base image the Dockerfile names, the OCI layout under `bases/` that supplies it, and the digest that layout must hold.

ReadyStack signs `rebuild.json` with its release key after the release gate and records the signature in the public Sigstore transparency log. The signature is made once the finished archive has passed that gate, so it is published beside the archive, not inside it: `ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json.sigstore`, at https://readystack.dev/api/kit/zitadel/v4.20.5-CE-ubuntu24.04-r1/files/ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json.sigstore, with a copy of the manifest as `ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json` at the same address without `.sigstore`.

The reference verifier ships in this archive as `docs/rebuild-bundle/rebuild_bundle.py` (Python 3 standard library, Docker with `buildx`, and cosign to check the signature); the same file is published with the specification. Download the key and the signature next to the kit directory, not into it: a file added inside the kit changes the tree hash, and `validate` then refuses the kit. From the directory this archive extracts to:

```
curl -fsSLo ../cosign.pub https://readystack.dev/keys/cosign.pub
curl -fsSLo ../ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json.sigstore https://readystack.dev/api/kit/zitadel/v4.20.5-CE-ubuntu24.04-r1/files/ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json.sigstore
python3 docs/rebuild-bundle/rebuild_bundle.py validate . --key ../cosign.pub --signature ../ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json.sigstore
python3 docs/rebuild-bundle/rebuild_bundle.py verify   . --key ../cosign.pub --signature ../ReadyStack-zitadel-v4.20.5-CE-ubuntu24.04-r1.rebuild.json.sigstore
```

`validate` builds nothing: it checks the signature over `rebuild.json`, `CHECKSUMS.sha256`, the tree hash, every base layout's digest and the builder archive. `verify` then rebuilds with the builder container's network egress blocked (iptables through `sudo -n`) and proves the block from inside the builder before building; it exits 0 only when the rebuilt image digest equals `subject.image_manifest_digest`. Other exit codes: 1 the archive is not valid, 2 the rebuilt digest differs, 3 isolation could not be proven (a build with `--isolate none` always ends here, never as verified), 4 the build did not complete.

## SLSA provenance on your own build platform

```
./BUILD_OFFLINE.sh --provenance   # the same rebuild, with SLSA v1 build provenance (mode=max) attached
                                  # to the image in rebuilt.oci.tar; the image digest is unchanged
./VERIFY_OFFLINE.sh               # checks that image digest: it reads the image manifest inside the
                                  # provenance index, so the comparison is the same with or without it
```

What this kit supplies: a complete, pinned build definition (vendored source, dependencies and base images, a pinned BuildKit), run with the network off on a fresh builder for every build, and provenance generated by BuildKit itself rather than by any build step.

What your build platform supplies: it runs the build and signs the provenance with a key the build steps cannot reach (for example `cosign attest` from the platform after the build). Any SLSA build level is your platform's; this archive claims none and does not, and cannot, certify your platform.

