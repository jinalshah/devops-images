#!/bin/bash
# Test script to verify AI CLI tools are available in the DevOps container
# This script should be run after building the DevOps images

set -e

IMAGE_NAME=${1:-"ghcr.io/jinalshah/devops/images/base:latest"}

echo "Testing AI CLI tools availability in DevOps container image: $IMAGE_NAME"
echo "==============================================================================="

# Track test results
FAILED_TESTS=0

# Test function
test_command() {
    local cmd_name="$1"
    local cmd_path="$2"

    echo "Testing $cmd_name command..."
    if docker run --rm "$IMAGE_NAME" command -v "$cmd_path" >/dev/null 2>&1; then
        echo "✓ $cmd_name command is available"
        echo "  Location: $(docker run --rm "$IMAGE_NAME" which "$cmd_path" 2>/dev/null || echo 'unknown')"
    else
        echo "✗ $cmd_name command is NOT available"
        ((FAILED_TESTS++))
    fi
    echo
}

# Test version function
test_version() {
    local cmd_name="$1"
    local cmd_path="$2"
    local version_flag="${3:---version}"

    echo "Testing $cmd_name version..."
    if docker run --rm "$IMAGE_NAME" "$cmd_path" "$version_flag" >/dev/null 2>&1; then
        echo "✓ $cmd_name version check passed"
        echo "  Version: $(docker run --rm "$IMAGE_NAME" "$cmd_path" "$version_flag" 2>/dev/null | head -1 || echo 'unknown')"
    else
        echo "✗ $cmd_name version check failed"
        ((FAILED_TESTS++))
    fi
    echo
}

# Test Node.js and npm (prerequisites)
test_command "node" "node"
test_version "node" "node"

test_command "npm" "npm"
test_version "npm" "npm"

# Test AI CLI tools
test_command "Claude Code CLI" "claude"
test_version "Claude Code CLI" "claude"

test_command "GitHub Copilot CLI" "copilot"
test_version "GitHub Copilot CLI" "copilot"

test_command "OpenAI Codex CLI" "codex"
test_version "OpenAI Codex CLI" "codex"

test_command "Gemini CLI" "gemini"
test_version "Gemini CLI" "gemini"

echo
if [ $FAILED_TESTS -eq 0 ]; then
    echo "✓ All AI CLI tools are available and functional in the container image!"
    echo
    echo "Usage examples:"
    echo "  # Node.js"
    echo "  docker run --rm $IMAGE_NAME node --version"
    echo "  docker run --rm $IMAGE_NAME npm --version"
    echo
    echo "  # AI CLI tools"
    echo "  docker run --rm -it $IMAGE_NAME claude"
    echo "  docker run --rm -it $IMAGE_NAME copilot"
    echo "  docker run --rm -it $IMAGE_NAME codex"
    echo "  docker run --rm -it $IMAGE_NAME gemini"
    exit 0
else
    echo "✗ $FAILED_TESTS test(s) failed!"
    exit 1
fi
