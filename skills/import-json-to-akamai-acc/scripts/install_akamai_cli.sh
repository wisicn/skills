#!/bin/bash

# Akamai CLI Installation Script
# This script will download and install Akamai CLI, and configure environment variables

set -e

# Detect OS and architecture
detect_os() {
    local OS_NAME
    local ARCH_NAME

    case "$(uname -s)" in
        Linux*)
            OS_NAME="linux"
            ;;
        Darwin*)
            OS_NAME="darwin"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            OS_NAME="windows"
            ;;
        *)
            echo "❌ Unsupported operating system: $(uname -s)" >&2
            exit 1
            ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64)
            ARCH_NAME="amd64"
            ;;
        arm64|aarch64)
            ARCH_NAME="arm64"
            ;;
        i386|i686)
            ARCH_NAME="386"
            ;;
        *)
            echo "❌ Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac

    echo "${OS_NAME}${ARCH_NAME}"
}

# Get latest version from GitHub API
get_latest_version() {
    echo "Fetching latest Akamai CLI version from GitHub..." >&2

    if ! command -v curl &> /dev/null; then
        echo "❌ curl is required but not installed" >&2
        exit 1
    fi

    local LATEST_VERSION
    local DOWNLOAD_URL
    local ASSET_NAME

    # Get the latest release info
    local RELEASE_INFO
    RELEASE_INFO=$(curl -s "https://api.github.com/repos/akamai/cli/releases/latest")

    # Extract version
    LATEST_VERSION=$(echo "$RELEASE_INFO" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')

    if [ -z "$LATEST_VERSION" ]; then
        echo "❌ Failed to fetch latest version from GitHub" >&2
        exit 1
    fi

    echo "✅ Latest version: v${LATEST_VERSION}" >&2

    # Find correct asset for this platform
    local PLATFORM=$(detect_os)

    # Extract correct asset name from the release
    # Actual pattern is: akamai-v{VERSION}-{PLATFORM}
    # Note: For macOS, the asset name uses "mac" not "darwin"
    local SEARCH_PLATFORM=$PLATFORM
    if [ "$PLATFORM" = "darwinamd64" ]; then
        SEARCH_PLATFORM="macamd64"
    elif [ "$PLATFORM" = "darwinarm64" ]; then
        SEARCH_PLATFORM="macarm64"
    fi

    # Try pattern: akamai-v{VERSION}-{PLATFORM}
    if echo "$RELEASE_INFO" | grep -q "\"name\": \"akamai-v${LATEST_VERSION}-${SEARCH_PLATFORM}\""; then
        ASSET_NAME="akamai-v${LATEST_VERSION}-${SEARCH_PLATFORM}"
    # Try pattern without version: akamai-{PLATFORM}
    elif echo "$RELEASE_INFO" | grep -q "\"name\": \"akamai-${SEARCH_PLATFORM}\""; then
        ASSET_NAME="akamai-${SEARCH_PLATFORM}"
    else
        # List available assets for debugging
        echo "❌ Could not find matching asset for platform: ${PLATFORM}" >&2
        echo "Available assets:" >&2
        echo "$RELEASE_INFO" | grep '"name":' | sed 's/.*"name": "\(.*\)".*/  - \1/' >&2
        exit 1
    fi

    # Extract the browser_download_url for the found asset
    # Use awk to find the asset with matching name and extract its URL
    DOWNLOAD_URL=$(echo "$RELEASE_INFO" | awk -v name="$ASSET_NAME" '
        /"name":/ {
            # Remove whitespace and quotes to check if this is our asset
            line = $0
            gsub(/[[:space:]]/, "", line)
            if (line ~ "\"name\":\"" name "\"") {
                found = 1
            }
        }
        found && /"browser_download_url":/ {
            # Extract the URL value
            gsub(/.*"browser_download_url":[[:space:]]*"/, "")
            gsub(/".*/, "")
            print
            exit
        }
    ')

    if [ -z "$DOWNLOAD_URL" ]; then
        echo "❌ Failed to extract download URL for ${ASSET_NAME}" >&2
        echo "Debug: Searching in release info..." >&2
        exit 1
    fi

    echo "Found asset: ${ASSET_NAME}" >&2
    echo "$DOWNLOAD_URL"
}

# Variables
INSTALL_DIR="/usr/local/bin"
AKAMAI_PLATFORM=$(detect_os)
DOWNLOAD_URL=$(get_latest_version)

echo "Detected platform: ${AKAMAI_PLATFORM}"

# Check if already installed
if command -v akamai &> /dev/null; then
    echo "Akamai CLI is already installed. Version information:"
    akamai --version
    echo ""
    echo "To update to the latest version, please manually remove the existing installation first:"
    echo "  sudo rm ${INSTALL_DIR}/akamai"
    exit 0
fi

echo "Starting installation of Akamai CLI..."

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download Akamai CLI
echo "Downloading Akamai CLI from ${DOWNLOAD_URL}..."

if command -v wget &> /dev/null; then
    echo "Using wget to download..." >&2
    if ! wget "$DOWNLOAD_URL" -O akamai; then
        echo "❌ Download failed using wget" >&2
        exit 1
    fi
elif command -v curl &> /dev/null; then
    echo "Using curl to download..." >&2
    if ! curl -fL "$DOWNLOAD_URL" -o akamai; then
        echo "❌ Download failed using curl" >&2
        exit 1
    fi
else
    echo "❌ Either wget or curl is required for download" >&2
    exit 1
fi

# Verify file was downloaded
if [ ! -f akamai ]; then
    echo "❌ Downloaded file not found" >&2
    exit 1
fi

# Check if file has content
if [ ! -s akamai ]; then
    echo "❌ Downloaded file is empty" >&2
    exit 1
fi

# Show file size
FILE_SIZE=$(ls -lh akamai | awk '{print $5}')
echo "Downloaded file size: ${FILE_SIZE}"

# Set execute permissions and install
echo "Setting execute permissions..." >&2
if ! chmod +x akamai; then
    echo "❌ Failed to set execute permissions" >&2
    exit 1
fi

echo "Moving to ${INSTALL_DIR}..." >&2
if ! sudo mv akamai "$INSTALL_DIR/akamai"; then
    echo "❌ Failed to install to ${INSTALL_DIR}" >&2
    echo "You may need to check sudo permissions or run with appropriate privileges" >&2
    exit 1
fi

# Verify installation
if command -v akamai &> /dev/null; then
    echo "✅ Akamai CLI installed successfully!"
    akamai --version
else
    echo "❌ Akamai CLI installation failed" >&2
    exit 1
fi

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo ""
echo "Installation complete! Run 'akamai --help' to view available commands."
