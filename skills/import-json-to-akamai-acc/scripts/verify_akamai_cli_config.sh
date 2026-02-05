#!/bin/bash

# Verify Akamai CLI configuration
# This script checks if Akamai CLI is properly configured and can communicate with Akamai Control Center

set -e

echo "🔍 Verifying Akamai CLI property-manager Command..."

# Check if property-manager package is installed
echo ""
echo "🔍 Checking property-manager Command..."

# Capture the help output to verify property-manager is actually installed
HELP_OUTPUT=$(akamai property-manager --help 2>&1) || true

# Check if output contains "Usage: akamai property-manager" (indicates successful installation)
# If not installed, it will show base CLI help with just "Usage:"
if echo "$HELP_OUTPUT" | grep -q "Usage: akamai property-manager"; then
    echo "✅ property-manager package is installed"
else
    echo "⚠️ property-manager package not installed, attempting to install..."
    echo ""
    
    # Try to install property-manager and capture output
    INSTALL_OUTPUT=$(akamai install property-manager 2>&1) || true
    echo "$INSTALL_OUTPUT"
    echo ""
    
    # Verify installation by checking if property-manager help works
    HELP_OUTPUT=$(akamai property-manager --help 2>&1) || true
    
    # Check if output contains "Usage: akamai property-manager" (indicates successful installation)
    if echo "$HELP_OUTPUT" | grep -q "Usage: akamai property-manager"; then
        echo "✅ property-manager package installed successfully"
    # Check for "already exists" error and try update
    elif echo "$INSTALL_OUTPUT" | grep -q "Package directory already exists"; then
        echo "⚠️ Package directory already exists, attempting to update..."
        echo ""
        
        UPDATE_OUTPUT=$(akamai update property-manager 2>&1) || true
        echo "$UPDATE_OUTPUT"
        echo ""
        
        # Verify update by checking help again
        HELP_OUTPUT=$(akamai property-manager --help 2>&1) || true
        
        if echo "$HELP_OUTPUT" | grep -q "Usage: akamai property-manager"; then
            echo "✅ property-manager package is ready"
        else
            echo "⚠️ Update completed but verification pending"
        fi
    else
        echo ""
        echo "❌ Failed to install property-manager package"
        echo "Please check your internet connection and try again"
        exit 1
    fi
fi

# Test configuration by listing property groups
echo ""
echo "🔧 Testing Akamai CLI configuration..."
echo "Running: akamai --section default pm list-groups --format json"
echo ""

# Capture output and check for success
TEST_OUTPUT=$(akamai --section default pm lc --format json 2>&1) || true

# Check if output contains valid JSON (starts with '[')
if echo "$TEST_OUTPUT" | grep -q '^\['; then
    echo "✅ Akamai CLI configuration is working correctly"
    echo "Configuration test passed!"
    echo ""
    echo "Available ACC contract:"
    echo "$TEST_OUTPUT" | head -20
    
    # Count groups
    GROUP_COUNT=$(echo "$TEST_OUTPUT" | grep -c '"contractId"' || echo "0")
    echo ""
    echo "Total contracts found: $GROUP_COUNT"
    exit 0
else
    echo "❌ Akamai CLI configuration test failed"
    echo ""
    
    # Check for specific error patterns
    if echo "$TEST_OUTPUT" | grep -q "invalid_client"; then
        echo "Error: Authentication failed - invalid client credentials"
        echo "Please verify your .edgerc file contains correct credentials"
    elif echo "$TEST_OUTPUT" | grep -q "Unable to connect"; then
        echo "Error: Unable to connect to Akamai API"
        echo "Please check your network connection and proxy settings"
    elif echo "$TEST_OUTPUT" | grep -q "Usage:"; then
        echo "Error: Command not recognized or authentication failed"
        echo "This usually indicates missing or invalid .edgerc configuration"
    else
        echo "Error output:"
        echo "$TEST_OUTPUT"
    fi
    
    echo ""
    echo "❌ BLOCKING ERROR: Cannot continue without valid Akamai PAPI client credentials"
    echo ""
    echo "This is a blocking issue. The process must abort."
    echo ""
    echo "To start over:"
    echo "  1. Create a new $HOME/.edgerc file with valid credentials"
    echo "  2. Follow the setup guide: https://techdocs.akamai.com/developer/docs/edgegrid"
    echo "  3. Then restart this process"
    exit 1
fi
