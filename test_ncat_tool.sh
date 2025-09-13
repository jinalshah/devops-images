#!/bin/bash
# Test script to verify ncat tool is available in the DevOps container
# This script should be run after building the DevOps images

set -e

IMAGE_NAME=${1:-"ghcr.io/jinalshah/devops/images/base:latest"}

echo "Testing ncat tool availability in DevOps container image: $IMAGE_NAME"
echo "==============================================================================="

# Test ncat command availability
echo "Testing ncat command..."
if docker run --rm "$IMAGE_NAME" command -v ncat >/dev/null 2>&1; then
    echo "✓ ncat command is available"
    echo "  Location: $(docker run --rm "$IMAGE_NAME" which ncat 2>/dev/null || echo 'unknown')"
else
    echo "✗ ncat command is NOT available"
    exit 1
fi

echo

# Test ncat version and basic functionality
echo "Testing ncat version..."
if docker run --rm "$IMAGE_NAME" ncat --version >/dev/null 2>&1; then
    echo "✓ ncat version check passed"
    echo "  Version: $(docker run --rm "$IMAGE_NAME" ncat --version 2>/dev/null | head -1 || echo 'unknown')"
else
    echo "✗ ncat version check failed"
    exit 1
fi

echo

# Test ncat help functionality
echo "Testing ncat help..."
if docker run --rm "$IMAGE_NAME" ncat --help >/dev/null 2>&1; then
    echo "✓ ncat help command works"
else
    echo "✗ ncat help command failed"
    exit 1
fi

echo
echo "✓ ncat tool is available and functional in the container image!"
echo
echo "Usage examples:"
echo "  docker run --rm $IMAGE_NAME ncat --version"
echo "  docker run --rm $IMAGE_NAME ncat --help"
echo "  docker run --rm -it $IMAGE_NAME ncat -l -p 8080  # Listen on port 8080"
echo "  docker run --rm $IMAGE_NAME ncat google.com 80   # Connect to Google on port 80"