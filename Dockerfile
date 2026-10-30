# Custom Janus Gateway image for the ARCSIP SIP <-> WebRTC media gateway.
#
# Pinned to the digest `canyan/janus-gateway:latest` has pointed at since
# 2023-05-20: Janus 1.1.4, SIP plugin 0.0.8 — what the gateway runs today. The
# dialer is written against this version's event shapes (e.g. `call_id` beside
# the SIP `result`), so moving Janus is a dialer change, not just a rebuild.
FROM canyan/janus-gateway@sha256:80970d0b1c407222e2f88d7a6d31a16686fb9a5145a491b4b4d843ee40ee4ce1

# Default public IP, baked in as the NAT_PUBLIC_IP default. Override at deploy
# time with the NAT_PUBLIC_IP environment variable (see docker-compose.yml).
ARG PUBLIC_IP=5.78.103.238
ENV NAT_PUBLIC_IP=${PUBLIC_IP}

# Config is staged in /tmp and copied into the image's real config dir at
# startup (its location varies between base-image builds).
COPY janus-config/ /tmp/janus-config/
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []
