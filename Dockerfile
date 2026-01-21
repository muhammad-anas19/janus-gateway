# Custom Janus Gateway with proper NAT configuration
FROM canyan/janus-gateway:latest

# Set the public IP as a build argument (can be overridden)
ARG PUBLIC_IP=5.78.103.238

# Copy our custom config files
COPY janus-config/janus.jcfg /opt/janus/etc/janus/janus.jcfg
COPY janus-config/janus.plugin.sip.jcfg /opt/janus/etc/janus/janus.plugin.sip.jcfg
COPY janus-config/janus.transport.websockets.jcfg /opt/janus/etc/janus/janus.transport.websockets.jcfg
COPY janus-config/janus.transport.http.jcfg /opt/janus/etc/janus/janus.transport.http.jcfg

# Create startup script that configures NAT at runtime
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Get public IP from environment or use default\n\
PUBLIC_IP="${NAT_PUBLIC_IP:-5.78.103.238}"\n\
\n\
echo "Configuring Janus with public IP: $PUBLIC_IP"\n\
\n\
# Update janus.jcfg with public IP\n\
sed -i "s/nat_1_1_mapping = .*/nat_1_1_mapping = \"$PUBLIC_IP\"/" /opt/janus/etc/janus/janus.jcfg\n\
\n\
# Update janus.plugin.sip.jcfg with public IP\n\
sed -i "s/sdp_ip = .*/sdp_ip = \"$PUBLIC_IP\"/" /opt/janus/etc/janus/janus.plugin.sip.jcfg\n\
sed -i "s/rtp_ip = .*/rtp_ip = \"$PUBLIC_IP\"/" /opt/janus/etc/janus/janus.plugin.sip.jcfg\n\
\n\
# Show the configuration for verification\n\
echo "=== NAT Configuration ==="\n\
grep -E "nat_1_1|sdp_ip|rtp_ip" /opt/janus/etc/janus/janus.jcfg /opt/janus/etc/janus/janus.plugin.sip.jcfg || true\n\
echo "========================"\n\
\n\
# Start Janus\n\
exec /opt/janus/bin/janus "$@"\n\
' > /entrypoint.sh && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
