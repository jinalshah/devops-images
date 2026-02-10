#!/bin/bash
set -e

# ============================================================================
# Entrypoint: match devops user UID/GID to workspace mount owner
# ============================================================================
# This script runs as root. It detects the UID/GID of the mounted workspace
# directory and adjusts the devops user to match, ensuring seamless read/write
# access to volume mounts. Finally, it drops privileges via gosu.
#
# Rootless Podman: detected automatically. The container stays as root (which
# IS the unprivileged host user) with HOME=/home/devops for shell configs.
# For a cleaner experience, use: --userns=keep-id:uid=1000,gid=1000
# ============================================================================

# If not running as root, skip UID/GID remapping (user was explicitly set)
if [ "$(id -u)" != "0" ]; then
    exec "$@"
fi

DEVOPS_USER="devops"
DEVOPS_HOME="/home/devops"

# Current UID/GID of the devops user (build-time defaults)
CURRENT_UID=$(id -u "${DEVOPS_USER}")
CURRENT_GID=$(id -g "${DEVOPS_USER}")

# Probe common mount paths for UID detection (priority order)
# A directory is considered a mount if its UID differs from build-time default
HOST_UID=""
HOST_GID=""
for probe_dir in "${WORKSPACE_DIR}" /workspace /srv "${PWD}"; do
    if [ -n "${probe_dir}" ] && [ -d "${probe_dir}" ]; then
        PROBE_UID=$(stat -c '%u' "${probe_dir}" 2>/dev/null || echo "")
        PROBE_GID=$(stat -c '%g' "${probe_dir}" 2>/dev/null || echo "")

        # Found a mount: UID differs from current devops UID, or is 0 (root/Podman)
        if [ -n "${PROBE_UID}" ] && { [ "${PROBE_UID}" != "${CURRENT_UID}" ] || [ "${PROBE_UID}" = "0" ]; }; then
            HOST_UID="${PROBE_UID}"
            HOST_GID="${PROBE_GID}"
            break
        fi
    fi
done

# Fallback: no mount detected, keep build-time defaults
HOST_UID="${HOST_UID:-${CURRENT_UID}}"
HOST_GID="${HOST_GID:-${CURRENT_GID}}"

# Detect rootless Podman (Podman creates /run/.containerenv; rootless adds rootless=1)
is_rootless_podman() {
    [ -f /run/.containerenv ] && grep -q 'rootless=1' /run/.containerenv 2>/dev/null
}

# Rootless Podman: "root" is actually the unprivileged host user.
# Mounted files appear as root:root. Dropping to devops would break access.
# Stay as root with HOME set to devops's home for shell configs.
if [ "${HOST_UID}" = "0" ] && is_rootless_podman; then
    export HOME="${DEVOPS_HOME}"
    exec "$@"
fi

# Skip UID/GID remapping when:
# 1. Host UID is 0 (root) - handles macOS Docker Desktop with VirtioFS/gRPC-FUSE
#    where mounts appear as root but permissions are handled transparently
# 2. Host UID already matches devops user (no change needed)
if [ "${HOST_UID}" != "0" ] && [ "${HOST_UID}" != "${CURRENT_UID}" ]; then

    # Update GID first (if different)
    if [ "${HOST_GID}" != "${CURRENT_GID}" ]; then
        groupmod -g "${HOST_GID}" "${DEVOPS_USER}"
    fi

    # Update UID
    usermod -u "${HOST_UID}" "${DEVOPS_USER}"

    # Fix ownership of non-mounted home directory contents
    # These are files created during the Docker build that now have the old UID
    chown -R "${DEVOPS_USER}:${DEVOPS_USER}" \
        "${DEVOPS_HOME}/.oh-my-zsh" \
        "${DEVOPS_HOME}/.zshrc" \
        "${DEVOPS_HOME}/.bashrc" \
        "${DEVOPS_HOME}/bin" \
        "${DEVOPS_HOME}/.terraform.versions" \
        "${DEVOPS_HOME}/.tfswitch.toml" \
        "${DEVOPS_HOME}/.config" \
        "${DEVOPS_HOME}/.local" \
        2>/dev/null || true

elif [ "${HOST_GID}" != "0" ] && [ "${HOST_GID}" != "${CURRENT_GID}" ]; then
    # Edge case: only GID differs (UID matches but GID does not)
    groupmod -g "${HOST_GID}" "${DEVOPS_USER}"

    chown -R :"${DEVOPS_USER}" \
        "${DEVOPS_HOME}/.oh-my-zsh" \
        "${DEVOPS_HOME}/.zshrc" \
        "${DEVOPS_HOME}/.bashrc" \
        "${DEVOPS_HOME}/bin" \
        "${DEVOPS_HOME}/.terraform.versions" \
        "${DEVOPS_HOME}/.tfswitch.toml" \
        "${DEVOPS_HOME}/.config" \
        "${DEVOPS_HOME}/.local" \
        2>/dev/null || true
fi

# Drop privileges and exec the CMD
exec gosu "${DEVOPS_USER}" "$@"
