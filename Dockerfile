# Custom Janus Gateway image for the ARCSIP SIP <-> WebRTC media gateway.
#
# NOTE: pin the base image to a digest for reproducible production builds, e.g.
#   FROM canyan/janus-gateway@sha256:<digest>
# `:latest` is non-reproducible — a rebuild can silently change the Janus
# version. Pin once you've validated a specific tag/digest.
FROM canyan/janus-gateway:latest

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
