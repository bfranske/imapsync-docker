# syntax=docker/dockerfile:1

FROM debian:bookworm-slim

ARG IMAPSYNC_VERSION=unknown
ARG VCS_REF=unknown
ARG BUILD_DATE=unknown

LABEL org.opencontainers.image.title="imapsync" \
      org.opencontainers.image.description="Multi-architecture imapsync CLI image" \
      org.opencontainers.image.version="${IMAPSYNC_VERSION}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.source="https://github.com/bfranske/imapsync-docker"

RUN apt-get update \
    && apt-get install --yes --no-install-recommends \
        ca-certificates \
        libauthen-ntlm-perl \
        libcgi-pm-perl \
        libcrypt-openssl-rsa-perl \
        libdata-uniqid-perl \
        libencode-imaputf7-perl \
        libfile-copy-recursive-perl \
        libfile-tail-perl \
        libhttp-daemon-perl \
        libhttp-daemon-ssl-perl \
        libhttp-message-perl \
        libhtml-parser-perl \
        libio-socket-inet6-perl \
        libio-socket-ssl-perl \
        libio-tee-perl \
        libjson-webtoken-perl \
        libmail-imapclient-perl \
        libmodule-scandeps-perl \
        libnet-dns-perl \
        libnet-server-perl \
        libparse-recdescent-perl \
        libproc-processtable-perl \
        libreadonly-perl \
        libregexp-common-perl \
        libsys-meminfo-perl \
        libterm-readkey-perl \
        libunicode-string-perl \
        liburi-perl \
        libwww-perl \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --create-home --uid 10001 imapsync

COPY upstream/imapsync /usr/local/bin/imapsync
COPY docker/entrypoint.sh /usr/local/bin/imapsync-entrypoint

RUN chmod 0555 /usr/local/bin/imapsync /usr/local/bin/imapsync-entrypoint \
    && mkdir --parents /home/imapsync/logs \
    && chown imapsync:imapsync /home/imapsync/logs \
    && /usr/local/bin/imapsync --version

USER imapsync
WORKDIR /home/imapsync

ENTRYPOINT ["/usr/local/bin/imapsync-entrypoint"]
CMD []