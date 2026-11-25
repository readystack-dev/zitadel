# GENERATED L-009 hermetic build (--network=none, SBOM+SLSA-attestation-producing).
# Pinned bases from BASE_IMAGE_DIGESTS.lock; vendored Go tree + debs from Dockerfile.vendor.
FROM golang:1.26.11-bookworm@sha256:dc40a13b61304647ed7e5d581d246b86413dfc29d63c6d018310feb93cd98fc0 AS build_zitadel
WORKDIR /src
COPY vendored/zitadel-src/ .
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOWORK=off GOFLAGS="-mod=vendor -buildvcs=false" GOPROXY=off SOURCE_DATE_EPOCH=1795404451
RUN go build -trimpath -ldflags='-s -w -X github.com/zitadel/zitadel/cmd/build.version=v4.20.5' -o /zitadel . && /zitadel --version && \
    { readelf -lW /zitadel | sed -n 's/.*Requesting program interpreter: \(.*\)]$/\1/p'; readelf -dW /zitadel | sed -n 's/.*Shared library: \[\(.*\)\]$/\1/p'; } > /zitadel.needs
# rs-probe: the HEALTHCHECK helper (standard library only, from the kit's rs-probe.go)
FROM golang:1.26.11-bookworm@sha256:dc40a13b61304647ed7e5d581d246b86413dfc29d63c6d018310feb93cd98fc0 AS build_rs_probe
WORKDIR /probe
COPY rs-probe.go main.go
COPY rs-probe.mod go.mod
ENV CGO_ENABLED=0 GOTOOLCHAIN=local GOFLAGS="-buildvcs=false" GOPROXY=off SOURCE_DATE_EPOCH=1795404451
RUN go build -trimpath -ldflags='-s -w' -o /rs-probe .
# the chiselled rootfs (vendored/chisel, cut by Dockerfile.vendor), the service user, the binaries
FROM ubuntu:24.04@sha256:9c7f200c07e3d4a03e7249d2c16bf66a51120fb876aa2242cf31451412543289 AS rootfs
ARG SOURCE_DATE_EPOCH=1795404451
ADD vendored/chisel/rootfs.tar /rootfs/
RUN printf 'zitadel:x:999:999::/home/zitadel:/bin/sh\n' >> /rootfs/etc/passwd && printf 'zitadel:x:999:\n' >> /rootfs/etc/group && \
    mkdir -p /rootfs/home/zitadel && chown -R 999:999 /rootfs/home/zitadel
COPY --from=build_zitadel /zitadel /rootfs/usr/local/bin/zitadel
COPY --from=build_zitadel /zitadel.needs /tmp/needs/zitadel
COPY --from=build_rs_probe /rs-probe /rootfs/usr/local/bin/rs-probe
COPY readystack-entrypoint.sh /rootfs/usr/local/bin/readystack-entrypoint.sh
RUN chmod 755 /rootfs/usr/local/bin/zitadel /rootfs/usr/local/bin/rs-probe && \
    chown 999:999 /rootfs/usr/local/bin/readystack-entrypoint.sh && \
    chmod 0755 /rootfs/usr/local/bin/readystack-entrypoint.sh
RUN --mount=type=bind,source=vendored/chisel,target=/chisel set -eu; \
    for n in /tmp/needs/*; do while read -r lib; do [ -n "$lib" ] || continue; \
      case "$lib" in /*) [ -e "/rootfs$lib" ] ;; *) [ -n "$(find /rootfs/usr/lib /rootfs/usr/lib64 -name "$lib" 2>/dev/null | head -1)" ] ;; esac || \
      { echo "$(basename "$n") needs $lib, which the chiselled rootfs does not have: add its slice to runtime_base.slices" >&2; exit 1; }; \
    done < "$n"; done; rm -rf /tmp/needs; \
    [ -e /rootfs/etc/os-release ] || { echo "no /etc/os-release: base-files_release-info is missing" >&2; exit 1; }; \
    [ "$(grep -c '^Package: ' /rootfs/var/lib/dpkg/status)" = "$(wc -l < /chisel/packages.tsv)" ] || \
      { echo "/var/lib/dpkg/status does not list every package of vendored/chisel/packages.tsv" >&2; exit 1; }; \
    rm -rf /rootfs/var/log/dpkg.log /rootfs/var/log/alternatives.log /rootfs/var/log/apt /rootfs/var/cache/ldconfig/aux-cache /rootfs/var/cache/fontconfig
FROM scratch
ARG SOURCE_DATE_EPOCH=1795404451
COPY --from=rootfs /rootfs/ /
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin ZITADEL_DEFAULTINSTANCE_FEATURES_LOGINV2_REQUIRED=false
LABEL org.opencontainers.image.licenses="AGPL-3.0-only"
LABEL com.readystack.license.disclosure="This image includes ZITADEL (https://github.com/zitadel/zitadel), licensed under AGPL-3.0-only. Modifications: one line in internal/i18n/translator.go stops the 'missing translation' warning from logging its arguments, which include one-time password-reset, email-verification and initial-password codes; full diff at https://readystack.dev/source/zitadel/v4.20.5/zitadel-v4.20.5-readystack.patch. Other security patches are applied only via vendored updates to upstream-published Go-module and apt dependencies (unmodified). ReadyStack license holders have access to the image build recipe and patched-package manifest on request via contact@readystack.dev."
LABEL org.opencontainers.image.title="ZITADEL"
LABEL org.opencontainers.image.source="https://github.com/zitadel/zitadel"
LABEL org.opencontainers.image.version="v4.20.5-CE-ubuntu24.04-r1"
LABEL org.opencontainers.image.revision="59827a8ec6dd0c23acbba5d0ebdf41fdc857d66c"
HEALTHCHECK --interval=5s --timeout=90s --start-period=30s \
  CMD /usr/local/bin/rs-probe http://127.0.0.1:8080/debug/healthz || exit 1
USER zitadel
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/readystack-entrypoint.sh"]
