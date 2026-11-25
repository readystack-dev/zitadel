#!/usr/bin/env bash
# =============================================================================
# ReadyStack — verify the offline rebuild.
#
#   1. asserts the rebuilt linux/amd64 image-manifest digest equals the digest
#      we published for this release (TARGET_DIGEST.txt),
#   2. loads the rebuilt image, boots it, and asserts its health probe.
#
# `--online` additionally binds the archive to the LIVE registry tag: it proves
# the published tag really contains the digest you just reproduced.
# =============================================================================
set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

ONLINE=0; [ "${1:-}" = "--online" ] && ONLINE=1
fail(){ echo "FAIL: $*" >&2; exit 1; }

[ -f rebuilt.oci.tar ]   || fail "rebuilt.oci.tar missing — run ./BUILD_OFFLINE.sh first"
[ -f TARGET_DIGEST.txt ]  || fail "TARGET_DIGEST.txt missing — not a reproducible archive"
# Read the digest from the image YOUR build produced — never from a text file that could have
# shipped in the archive (it once did: VERIFY then matched without any rebuild).
# The digest is the linux/amd64 IMAGE manifest, read the way BUILD_OFFLINE.sh reads it: after
# `BUILD_OFFLINE.sh --provenance`, index.json points at an index holding that manifest and its
# attestation manifest, and comparing the index's own digest reported a false DIGEST MISMATCH
# (held portainer 2.45.2, review rounds 1-4).
blob(){ tar -xOf rebuilt.oci.tar "blobs/sha256/$1" 2>/dev/null || tar -xOf rebuilt.oci.tar "./blobs/sha256/$1"; }
TOP=$(tar -xOf rebuilt.oci.tar index.json | jq -r '.manifests[0].digest')
TOPMT=$(tar -xOf rebuilt.oci.tar index.json | jq -r '.manifests[0].mediaType')
if [ "$TOPMT" = "application/vnd.oci.image.index.v1+json" ]; then
  X=$(blob "${TOP#sha256:}" | jq -r '[.manifests[] | select(.platform.os=="linux" and .platform.architecture=="amd64")][0].digest')
else
  X=$TOP
fi
[ -n "$X" ] && [ "$X" != "null" ] || fail "could not read the digest of rebuilt.oci.tar"
TARGET=$(awk -F= '/^image_manifest_digest=/{print $2}' TARGET_DIGEST.txt)
TAG=$(awk -F= '/^tag=/{print $2}' TARGET_DIGEST.txt)
[ -n "$TARGET" ] || fail "TARGET_DIGEST.txt has no image_manifest_digest"

echo "published : $TARGET"
echo "rebuilt   : $X"
if [ "$X" != "$TARGET" ]; then
  echo
  echo "DIGEST MISMATCH — the rebuild did not reproduce the published image." >&2
  echo "Environment for a bug report:" >&2
  echo "  docker    : $(docker version -f '{{.Server.Version}}' 2>/dev/null)" >&2
  echo "  buildx    : $(docker buildx version 2>/dev/null)" >&2
  echo "  kernel    : $(uname -sr)" >&2
  echo "  storage   : $(docker info -f '{{.Driver}}' 2>/dev/null)" >&2
  echo "  epoch     : $(cat SOURCE_DATE_EPOCH.txt 2>/dev/null)" >&2
  echo "Please send this block to support with rebuilt.oci.tar's index.json." >&2
  exit 2
fi
echo "==> DIGEST MATCH — this archive reproduces the published image bit-for-bit."

# --- boot + health ----------------------------------------------------------
# A product that needs services this archive does not contain (an external database) cannot be
# booted here; the digest match above is the reproducibility proof and the handbook covers the boot.
if grep -q '^verify_boot=skip' TARGET_DIGEST.txt 2>/dev/null; then
  echo "==> boot check skipped: $(sed -n 's/^verify_boot_reason=//p' TARGET_DIGEST.txt)"
elif grep -q '^verify_boot=oneshot$' TARGET_DIGEST.txt 2>/dev/null; then
# A cluster component (a Kubernetes or KubeVirt part) runs only inside a cluster: started alone it exits. It is
# checked by one run with the arguments below, which must exit 0 and print the expected text; its admin handbook
# covers the cluster boot.
[ -f rebuilt.docker.tar ] || fail "rebuilt.docker.tar missing — re-run ./BUILD_OFFLINE.sh"
IMG=$(docker load -i rebuilt.docker.tar | sed -n 's/.*\(sha256:[0-9a-f]\{64\}\).*/\1/p' | tail -1)
[ -n "$IMG" ] || IMG=$(docker load -i rebuilt.docker.tar | sed -n 's/^Loaded image: //p' | tail -1)
[ -n "$IMG" ] || fail "could not load the rebuilt image"
OSARGS=()
while IFS= read -r a; do OSARGS+=("$a"); done < <(sed -n 's/^verify_oneshot_arg=//p' TARGET_DIGEST.txt)
EXPECT=$(sed -n 's/^verify_oneshot_expect=//p' TARGET_DIGEST.txt | head -1)
[ "${#OSARGS[@]}" -gt 0 ] && [ -n "$EXPECT" ] || fail "TARGET_DIGEST.txt names a component check without its arguments"
# One run prints a version or usage and exits: one still going after 300 s fails the check (and is removed).
CN="readystack-verify-$$"
set +e
T0=$SECONDS
OUT=$(timeout -k 10 300 docker run --rm --name "$CN" --network none "$IMG" "${OSARGS[@]}" 2>&1); RC=$?
set -e
if [ "$RC" = 124 ] || { [ "$RC" = 137 ] && [ $((SECONDS - T0)) -ge 300 ]; }; then
  docker rm -f "$CN" >/dev/null 2>&1 || true
  tail -20 <<<"$OUT" >&2; fail "component check: \`${OSARGS[*]}\` did not finish within 300 s"
fi
[ "$RC" = 0 ] || { tail -20 <<<"$OUT" >&2; fail "component check: \`${OSARGS[*]}\` exited $RC"; }
# a here-string, not `printf | grep -q`: under pipefail grep's early exit left printf to die of SIGPIPE (141) once the
# output outgrew the pipe buffer, and a correct image failed as "lacks the expected text"
grep -qF -- "$EXPECT" <<<"$OUT" || { tail -20 <<<"$OUT" >&2; fail "component check: the output of \`${OSARGS[*]}\` lacks \"$EXPECT\""; }
echo "==> COMPONENT CHECK OK (\`${OSARGS[*]}\` printed \"$EXPECT\"; default user $(docker image inspect -f '{{.Config.User}}' "$IMG"))"
else
[ -f rebuilt.docker.tar ] || fail "rebuilt.docker.tar missing — re-run ./BUILD_OFFLINE.sh"
IMG=$(docker load -i rebuilt.docker.tar | sed -n 's/.*\(sha256:[0-9a-f]\{64\}\).*/\1/p' | tail -1)
[ -n "$IMG" ] || IMG=$(docker load -i rebuilt.docker.tar | sed -n 's/^Loaded image: //p' | tail -1)
[ -n "$IMG" ] || fail "could not load the rebuilt image"

PORT=$(awk -F= '/^probe_port=/{print $2}' TARGET_DIGEST.txt); PORT=${PORT:-80}
PATH_=$(sed -n 's/^probe_path=//p' TARGET_DIGEST.txt | head -1); PATH_=${PATH_:-/}   # the whole value: a query string has its own '='
HOSTPORT=$(( (RANDOM % 10000) + 20000 ))
CN="readystack-verify-$$"
docker rm -f "$CN" >/dev/null 2>&1 || true
# verify_env= lines: non-secret values the product needs just to start (e.g. a placeholder forge
# client for a CI server). They are printed, never secrets, and used only for this check.
ENVF=()
while IFS= read -r kv; do
  [ -n "$kv" ] || continue
  echo "    verify env: $kv"; ENVF+=(-e "$kv")
done < <(sed -n 's/^verify_env=//p' TARGET_DIGEST.txt)
# verify_secret= names a secret the product requires to start; a random throwaway value is made here.
while IFS= read -r k; do
  [ -n "$k" ] || continue
  echo "    verify secret: $k (random, this check only)"
  # Finite input: `tr </dev/urandom | head` makes tr die of SIGPIPE, which under pipefail + set -e
  # silently killed this script (G8 caught it on woodpecker 3.18.1).
  ENVF+=(-e "$k=$(head -c 18 /dev/urandom | base64 | LC_ALL=C tr -dc 'A-Za-z0-9')")
done < <(sed -n 's/^verify_secret=//p' TARGET_DIGEST.txt)
# loopback only: the check curls 127.0.0.1, and an image whose port is an unauthenticated admin surface (traefik's
# dashboard) must not be reachable from the network while it is verified
# verify_privileged=1: the product runs only with --privileged (its admin handbook says why); booted the same way here.
PRIV=()
if grep -q '^verify_privileged=1$' TARGET_DIGEST.txt 2>/dev/null; then
  echo "    verify flag: --privileged (this image is documented to run privileged)"; PRIV=(--privileged)
fi
# verify_cap_add= / verify_device=: a capability or device the product's documented start command adds (its admin
# handbook says which and why; wireguard: NET_ADMIN, /dev/net/tun). Only a capability name or a /dev path is accepted.
while IFS= read -r c; do
  [[ "$c" =~ ^[A-Z][A-Z_]*$ ]] || fail "TARGET_DIGEST.txt: verify_cap_add=$c is not a capability name"
  echo "    verify flag: --cap-add $c (documented)"; PRIV+=(--cap-add "$c")
done < <(sed -n 's/^verify_cap_add=//p' TARGET_DIGEST.txt)
while IFS= read -r d; do
  [[ "$d" =~ ^/dev/[A-Za-z0-9][A-Za-z0-9/_.-]*$ ]] || fail "TARGET_DIGEST.txt: verify_device=$d is not a /dev path"
  echo "    verify flag: --device $d (documented)"; PRIV+=(--device "$d")
done < <(sed -n 's/^verify_device=//p' TARGET_DIGEST.txt)
docker run -d --name "$CN" ${PRIV[@]+"${PRIV[@]}"} -p "127.0.0.1:$HOSTPORT:$PORT" ${ENVF[@]+"${ENVF[@]}"} "$IMG" >/dev/null
trap 'docker rm -f "$CN" >/dev/null 2>&1 || true' EXIT

# Healthy = any 2xx (some products answer 204). The boot window is the product's own
# (probe_timeout in TARGET_DIGEST.txt) — slow first boots are not failures.
WINDOW=$(awk -F= '/^probe_timeout=/{print $2}' TARGET_DIGEST.txt); WINDOW=${WINDOW:-180}
# probe_exec= : a product whose health check is a command, not an HTTP path (e.g. `valkey-cli ping`),
# is checked by running that command inside the container.
PEXEC=$(sed -n 's/^probe_exec=//p' TARGET_DIGEST.txt | head -1)
ok=0; waited=0
while [ "$waited" -lt "$WINDOW" ]; do
  if [ -n "$PEXEC" ]; then
    docker exec "$CN" sh -c "$PEXEC" >/dev/null 2>&1 && { ok=1; break; }
  else
    code=$(curl -s -o /dev/null -w '%{http_code}' "http://127.0.0.1:$HOSTPORT$PATH_" 2>/dev/null || true)
    case "$code" in 2??) ok=1; break ;; esac
  fi
  sleep 3; waited=$((waited + 3))
done
[ "$ok" = "1" ] || { docker logs "$CN" 2>&1 | tail -20; fail "rebuilt image did not pass its health check (${PEXEC:-HTTP 2xx on $PATH_}) within ${WINDOW}s"; }
echo "==> BOOT + HEALTH OK (non-root: $(docker exec "$CN" id -u 2>/dev/null))"
fi

# --- optional: bind the archive to the live registry tag --------------------
if [ "$ONLINE" = "1" ]; then
  [ -n "$TAG" ] || fail "--online needs tag= in TARGET_DIGEST.txt"
  echo "==> checking the live tag $TAG"
  LIVE=$(docker buildx imagetools inspect "$TAG" --raw 2>/dev/null \
        | jq -r '.manifests[]|select(.platform.architecture=="amd64" and .platform.os=="linux")|.digest' | head -1)
  [ -n "$LIVE" ] || fail "could not read the live tag's amd64 digest"
  echo "live tag  : $LIVE"
  [ "$LIVE" = "$X" ] || fail "the live tag does NOT contain the digest you reproduced"
  echo "==> LIVE TAG MATCH — the published tag contains exactly this image."
fi
echo
echo "VERIFIED."
