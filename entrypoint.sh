#!/bin/bash
set -e

echo "=== Initializing Mininet Environment ==="

# 1. Clean up the broken default service (just in case)
service openvswitch-switch stop 2>/dev/null || true

# 2. Start Open vSwitch manually to bypass WSL2 kernel limitations
echo "[*] Starting Open vSwitch daemons..."

# Create the OVS directories and database if they don't exist
mkdir -p /var/run/openvswitch
mkdir -p /etc/openvswitch
if [ ! -f /etc/openvswitch/conf.db ]; then
    ovsdb-tool create /etc/openvswitch/conf.db /usr/share/openvswitch/vswitch.ovsschema
fi

ovsdb-server --remote=punix:/var/run/openvswitch/db.sock \
             --remote=db:Open_vSwitch,Open_vSwitch,manager_options \
             --pidfile --detach >/dev/null 2>&1

ovs-vsctl --no-wait init
ovs-vswitchd --pidfile --detach >/dev/null 2>&1

# 3. Confirm the service is working
echo "[*] Open vSwitch Status:"
service openvswitch-switch status
ovs-vsctl show

# 4. Check for the controller
echo "[*] Controller Location:"
which ovs-testcontroller

# --- NEW: Dynamic Lab Workspace Setup ---
if [ -n "$LAB_NAME" ]; then
    echo "[*] Setting up workspace for lab: $LAB_NAME"
    mkdir -p "/home/student/${LAB_NAME}-output"
    # Change into the directory so the bash shell starts here
    cd "/home/student/${LAB_NAME}-output"
fi
# ----------------------------------------

# Force open permissions on all mounted folders
echo "[*] Unlocking volume permissions..."
chmod -R 777 /home/student 2>/dev/null || true

echo "=== Environment Ready ==="

# Execute the main container command (e.g., bash)
exec "$@"