# Custom Janus Gateway with proper NAT configuration
FROM canyan/janus-gateway:latest

# Copy our custom config files (these will override the defaults)
COPY janus-config/janus.jcfg /opt/janus/etc/janus/janus.jcfg
COPY janus-config/janus.plugin.sip.jcfg /opt/janus/etc/janus/janus.plugin.sip.jcfg
COPY janus-config/janus.transport.websockets.jcfg /opt/janus/etc/janus/janus.transport.websockets.jcfg
COPY janus-config/janus.transport.http.jcfg /opt/janus/etc/janus/janus.transport.http.jcfg

# The base image's entrypoint will start Janus automatically
