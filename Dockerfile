# Custom Janus Gateway with NAT configuration via command line
FROM canyan/janus-gateway:latest

# Your server's public IP
ARG PUBLIC_IP=5.78.103.238

# Copy config files to a temp location first, then find and copy to correct location at runtime
COPY janus-config/ /tmp/janus-config/

# Create entrypoint that finds config location and applies settings
RUN echo '#!/bin/sh\n\
set -e\n\
\n\
PUBLIC_IP="${NAT_PUBLIC_IP:-5.78.103.238}"\n\
echo "Setting up Janus with public IP: $PUBLIC_IP"\n\
\n\
# Find janus config directory\n\
CONFIG_DIR=""\n\
for dir in /opt/janus/etc/janus /usr/local/etc/janus /etc/janus; do\n\
    if [ -d "$dir" ]; then\n\
        CONFIG_DIR="$dir"\n\
        break\n\
    fi\n\
done\n\
\n\
if [ -z "$CONFIG_DIR" ]; then\n\
    echo "Creating config directory"\n\
    mkdir -p /opt/janus/etc/janus\n\
    CONFIG_DIR="/opt/janus/etc/janus"\n\
fi\n\
\n\
echo "Using config directory: $CONFIG_DIR"\n\
\n\
# Copy our config files\n\
cp /tmp/janus-config/*.jcfg "$CONFIG_DIR/" 2>/dev/null || true\n\
cp /tmp/janus-config/*.cfg "$CONFIG_DIR/" 2>/dev/null || true\n\
\n\
# Update NAT settings in all config files\n\
for f in "$CONFIG_DIR"/*.jcfg "$CONFIG_DIR"/*.cfg; do\n\
    if [ -f "$f" ]; then\n\
        sed -i "s/nat_1_1_mapping = .*/nat_1_1_mapping = \"$PUBLIC_IP\"/" "$f" 2>/dev/null || true\n\
        sed -i "s/sdp_ip = .*/sdp_ip = \"$PUBLIC_IP\"/" "$f" 2>/dev/null || true\n\
        sed -i "s/rtp_ip = .*/rtp_ip = \"$PUBLIC_IP\"/" "$f" 2>/dev/null || true\n\
    fi\n\
done\n\
\n\
echo "=== NAT Config ==="\n\
grep -r "nat_1_1\|sdp_ip\|rtp_ip" "$CONFIG_DIR"/ 2>/dev/null || echo "No NAT settings found"\n\
echo "=================="\n\
\n\
# Find and run janus\n\
JANUS=$(which janus 2>/dev/null || find /opt /usr -name "janus" -type f -executable 2>/dev/null | head -1)\n\
if [ -n "$JANUS" ]; then\n\
    echo "Starting Janus: $JANUS --nat-1-1=$PUBLIC_IP"\n\
    exec "$JANUS" --nat-1-1="$PUBLIC_IP" "$@"\n\
else\n\
    echo "ERROR: Janus not found"\n\
    exit 1\n\
fi\n\
' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD []
