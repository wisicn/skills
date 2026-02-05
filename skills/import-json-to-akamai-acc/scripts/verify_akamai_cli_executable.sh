#!/bin/bash

set -e

# Run 'akamai --version' and capture output
output=$(akamai --version 2>&1) || {
    echo "Error: Akamai CLI executable not found. Please install it with scripts/install_akamai_cli.sh" >&2
    exit 1
}

# Display the version information
echo "$output"
exit 0
