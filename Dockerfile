# Custom Janus Gateway with proper NAT configuration
# Using official meetecho image for better NAT support
FROM meetecho/janus-gateway:latest

# Your server's public IP
ARG PUBLIC_IP=5.78.103.238

# Copy our custom config files
COPY janus-config/janus.jcfg /usr/local/etc/janus/janus.jcfg
COPY janus-config/janus.plugin.sip.jcfg /usr/local/etc/janus/janus.plugin.sip.jcfg
COPY janus-config/janus.transport.websockets.jcfg /usr/local/etc/janus/janus.transport.websockets.jcfg
COPY janus-config/janus.transport.http.jcfg /usr/local/etc/janus/janus.transport.http.jcfg

# Update config with public IP at build time
RUN sed -i "s/nat_1_1_mapping = .*/nat_1_1_mapping = \"${PUBLIC_IP}\"/" /usr/local/etc/janus/janus.jcfg && \
    sed -i "s/sdp_ip = .*/sdp_ip = \"${PUBLIC_IP}\"/" /usr/local/etc/janus/janus.plugin.sip.jcfg && \
    sed -i "s/rtp_ip = .*/rtp_ip = \"${PUBLIC_IP}\"/" /usr/local/etc/janus/janus.plugin.sip.jcfg && \
    echo "=== Config verification ===" && \
    grep -E "nat_1_1|sdp_ip|rtp_ip" /usr/local/etc/janus/janus.jcfg /usr/local/etc/janus/janus.plugin.sip.jcfg || true
