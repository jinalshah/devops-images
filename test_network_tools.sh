#!/bin/bash
# Test script to verify network tools are available in the DevOps container
# This script should be run after building the DevOps images
# Combines testing for DNS tools (dig, nslookup) and network tools (ncat, telnet)

set -e

IMAGE_NAME=${1:-"ghcr.io/jinalshah/devops/images/base:latest"}

echo "Testing network tools availability in DevOps container image: $IMAGE_NAME"
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

# Test DNS tools
test_command "dig" "dig"
test_command "nslookup" "nslookup"

# Test network tools
test_command "ncat" "ncat"
test_command "telnet" "telnet"

# Additional functionality tests
echo "Testing ncat functionality..."
if docker run --rm "$IMAGE_NAME" ncat --version >/dev/null 2>&1; then
    echo "✓ ncat version check passed"
    echo "  Version: $(docker run --rm "$IMAGE_NAME" ncat --version 2>/dev/null | head -1 || echo 'unknown')"
else
    echo "✗ ncat version check failed"
    ((FAILED_TESTS++))
fi
echo

echo "Testing ncat help..."
if docker run --rm "$IMAGE_NAME" ncat --help >/dev/null 2>&1; then
    echo "✓ ncat help command works"
else
    echo "✗ ncat help command failed"
    ((FAILED_TESTS++))
fi

echo
if [ $FAILED_TESTS -eq 0 ]; then
    echo "✓ All network tools are available and functional in the container image!"
    echo
    echo "Usage examples:"
    echo "  # DNS tools"
    echo "  docker run --rm $IMAGE_NAME dig google.com"
    echo "  docker run --rm $IMAGE_NAME nslookup google.com"
    echo
    echo "  # Network tools" 
    echo "  docker run --rm $IMAGE_NAME ncat --version"
    echo "  docker run --rm $IMAGE_NAME ncat google.com 80"
    echo "  docker run --rm -it $IMAGE_NAME ncat -l -p 8080  # Listen on port 8080"
    echo "  docker run --rm $IMAGE_NAME telnet google.com 80"
    exit 0
else
    echo "✗ $FAILED_TESTS test(s) failed!"
    exit 1
fi