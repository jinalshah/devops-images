#!/bin/bash
# Architecture detection utility for cross-platform builds
# Sources this file to get architecture-specific values

# Define a shell function to determine the architecture value
get_arch_value() {
    arch=$(uname -m)
    case "$arch" in
        aarch64) echo "${1:-arm64}";;
        x86_64) echo "${2:-x86_64}";;
        *) echo "unknown";;
    esac
}

# Export common architecture values
export ARCH_VALUE=$(get_arch_value "arm64" "amd64")
export GHORG_ARCH_VALUE=$(get_arch_value "arm64" "x86_64")
export GCLOUD_ARCH_VALUE=$(get_arch_value "arm" "x86_64")
export SESSION_MANAGER_ARCH_VALUE=$(get_arch_value "arm64" "64bit")
