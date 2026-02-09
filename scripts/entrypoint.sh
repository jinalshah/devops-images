#!/bin/bash
set -e

# entrypoint.sh - Docker entrypoint for UID/GID remapping
#
# When DEVOPS_UID and/or DEVOPS_GID are set, remap the devops user/group
# to match the host user's IDs. This fixes volume mount permission issues.
#
# Usage:
#   docker run -e DEVOPS_UID=$(id -u) -e DEVOPS_GID=$(id -g) <image>

DEVOPS_USER="devops"
DEVOPS_GROUP="devops"
CURRENT_UID=$(id -u "$DEVOPS_USER")
CURRENT_GID=$(id -g "$DEVOPS_USER")
TARGET_UID="${DEVOPS_UID:-$CURRENT_UID}"
TARGET_GID="${DEVOPS_GID:-$CURRENT_GID}"

# -------------------------------------------------------------------
# If we are NOT running as root, the container was started with
# --user flag. Skip all remapping and just exec the CMD directly.
# -------------------------------------------------------------------
if [ "$(id -u)" != "0" ]; then
    exec "$@"
fi

# -------------------------------------------------------------------
# Guard against remapping devops to UID 0 (root)
# -------------------------------------------------------------------
if [ "$TARGET_UID" = "0" ]; then
    echo "ERROR: Cannot remap devops user to UID 0 (root)." >&2
    echo "If you need to run as root, use: docker run --user 0:0 ..." >&2
    exit 1
fi

# -------------------------------------------------------------------
# GID remapping (must happen before UID remapping)
# -------------------------------------------------------------------
if [ "$TARGET_GID" != "$CURRENT_GID" ]; then
    # Check if a group already owns this GID
    EXISTING_GROUP=$(getent group "$TARGET_GID" | cut -d: -f1 || true)
    if [ -n "$EXISTING_GROUP" ] && [ "$EXISTING_GROUP" != "$DEVOPS_GROUP" ]; then
        # Rename the conflicting group to free up the GID
        groupmod -g "$(shuf -i 60000-65000 -n 1)" "$EXISTING_GROUP"
    fi
    groupmod -g "$TARGET_GID" "$DEVOPS_GROUP"
fi

# -------------------------------------------------------------------
# UID remapping
# -------------------------------------------------------------------
if [ "$TARGET_UID" != "$CURRENT_UID" ]; then
    # Check if a user already owns this UID
    EXISTING_USER=$(getent passwd "$TARGET_UID" | cut -d: -f1 || true)
    if [ -n "$EXISTING_USER" ] && [ "$EXISTING_USER" != "$DEVOPS_USER" ]; then
        # Reassign the conflicting user to free up the UID
        usermod -u "$(shuf -i 60000-65000 -n 1)" "$EXISTING_USER"
    fi
    usermod -u "$TARGET_UID" "$DEVOPS_USER"
fi

# -------------------------------------------------------------------
# Fix ownership of build-time files only (skip mounted volumes)
#
# After UID remapping, mounted volumes already have the correct UID
# (they match the host user). We only need to chown files created
# during docker build that still carry the old UID/GID.
# -------------------------------------------------------------------
if [ "$TARGET_UID" != "$CURRENT_UID" ] || [ "$TARGET_GID" != "$CURRENT_GID" ]; then
    # Detect volume mounts under /home/devops and build prune rules
    PRUNE_ARGS=()
    while read -r mountpoint; do
        case "$mountpoint" in
            /home/devops/?*)
                PRUNE_ARGS+=(-path "$mountpoint" -prune -o)
                ;;
        esac
    done < <(awk '{print $5}' /proc/self/mountinfo)

    # Chown only non-mounted (build-time) files
    find /home/devops "${PRUNE_ARGS[@]}" -print0 \
        | xargs -0 chown "$DEVOPS_USER:$DEVOPS_GROUP" 2>/dev/null || true
fi

# -------------------------------------------------------------------
# Drop privileges and exec CMD as devops user
# -------------------------------------------------------------------
exec gosu "$DEVOPS_USER" "$@"
