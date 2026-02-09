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
# Fix ownership of home directory (only if remapping occurred)
# -------------------------------------------------------------------
if [ "$TARGET_UID" != "$CURRENT_UID" ] || [ "$TARGET_GID" != "$CURRENT_GID" ]; then
    chown -R "$TARGET_UID:$TARGET_GID" /home/devops
fi

# -------------------------------------------------------------------
# Drop privileges and exec CMD as devops user
# -------------------------------------------------------------------
exec gosu "$DEVOPS_USER" "$@"
