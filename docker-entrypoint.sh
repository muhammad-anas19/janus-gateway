#!/bin/sh
# Janus gateway entrypoint: stage config, inject runtime values, exec janus.
set -eu

# --- Required / tunable runtime values -------------------------------------
# NAT_PUBLIC_IP is baked as a build default (ENV in Dockerfile) and can be
# overridden at runtime. Fail loudly rather than silently advertising a wrong
# IP in ICE candidates / SDP.
: "${NAT_PUBLIC_IP:?NAT_PUBLIC_IP must be set to the server's public IP}"
PUBLIC_IP="$NAT_PUBLIC_IP"

# event_loops defaults to the host vCPU count; override with JANUS_EVENT_LOOPS.
EVENT_LOOPS="${JANUS_EVENT_LOOPS:-$(nproc 2>/dev/null || echo 4)}"

# Janus log verbosity (4=info, 3=warn). Lower = less stdout under load.
DEBUG_LEVEL="${JANUS_DEBUG_LEVEL:-4}"

echo "Janus startup: public_ip=$PUBLIC_IP event_loops=$EVENT_LOOPS debug_level=$DEBUG_LEVEL"

# --- Locate the config directory shipped by the base image -----------------
CONFIG_DIR=""
for dir in /opt/janus/etc/janus /usr/local/etc/janus /etc/janus; do
    if [ -d "$dir" ]; then
        CONFIG_DIR="$dir"
        break
    fi
done
if [ -z "$CONFIG_DIR" ]; then
    CONFIG_DIR=/opt/janus/etc/janus
    mkdir -p "$CONFIG_DIR"
fi
echo "Using config directory: $CONFIG_DIR"

# --- Stage our config and inject runtime values ----------------------------
cp /tmp/janus-config/*.jcfg "$CONFIG_DIR"/ 2>/dev/null || true

for f in "$CONFIG_DIR"/*.jcfg; do
    [ -f "$f" ] || continue
    sed -i "s/nat_1_1_mapping = .*/nat_1_1_mapping = \"$PUBLIC_IP\"/" "$f"
    sed -i "s/sdp_ip = .*/sdp_ip = \"$PUBLIC_IP\"/" "$f"
    sed -i "s/event_loops = .*/event_loops = $EVENT_LOOPS/" "$f"
    sed -i "s/debug_level = .*/debug_level = $DEBUG_LEVEL/" "$f"
done

# --- Locate and exec janus -------------------------------------------------
JANUS=$(command -v janus 2>/dev/null || find /opt /usr -name janus -type f -perm -u+x 2>/dev/null | head -1)
if [ -z "$JANUS" ]; then
    echo "ERROR: janus binary not found" >&2
    exit 1
fi

echo "Starting: $JANUS --nat-1-1=$PUBLIC_IP $*"
exec "$JANUS" --nat-1-1="$PUBLIC_IP" "$@"
