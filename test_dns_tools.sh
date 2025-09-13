#!/bin/bash
# Test script to verify dig and nslookup tools are available in the DevOps container
# This script should be run after building the DevOps images

set -e

IMAGE_NAME=${1:-"ghcr.io/jinalshah/devops/images/base:latest"}

echo "Testing DNS tools availability in DevOps container image: $IMAGE_NAME"
echo "==============================================================================="

# Test dig command availability
echo "Testing dig command..."
if docker run --rm "$IMAGE_NAME" command -v dig >/dev/null 2>&1; then
    echo "✓ dig command is available"
    echo "  Location: $(docker run --rm "$IMAGE_NAME" which dig 2>/dev/null || echo 'unknown')"
else
    echo "✗ dig command is NOT available"
    exit 1
fi

echo

# Test nslookup command availability
echo "Testing nslookup command..."
if docker run --rm "$IMAGE_NAME" command -v nslookup >/dev/null 2>&1; then
    echo "✓ nslookup command is available" 
    echo "  Location: $(docker run --rm "$IMAGE_NAME" which nslookup 2>/dev/null || echo 'unknown')"
else
    echo "✗ nslookup command is NOT available"
    exit 1
fi

echo
echo "✓ All DNS tools are available in the container image!"
echo
echo "Usage example:"
echo "  docker run --rm $IMAGE_NAME dig google.com"
echo "  docker run --rm $IMAGE_NAME nslookup google.com"