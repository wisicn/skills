#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

EDGERC_FILE="$HOME/.edgerc"
QUIET_MODE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -q|--quiet)
            QUIET_MODE=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

# Function to validate INI format with required pattern
validate_edgerc() {
    local file="$1"
    
    # Check if file exists
    if [[ ! -f "$file" ]]; then
        return 1
    fi
    
    # Check for [default] section
    if ! grep -q '^\[default\]$' "$file"; then
        return 1
    fi
    
    # Check for required fields
    if ! grep -qE '^client_secret\s*=' "$file"; then
        return 1
    fi
    
    if ! grep -qE '^host\s*=' "$file"; then
        return 1
    fi
    
    if ! grep -qE '^access_token\s*=' "$file"; then
        return 1
    fi
    
    if ! grep -qE '^client_token\s*=' "$file"; then
        return 1
    fi
    
    return 0
}

# Function to validate user input
validate_input() {
    local input="$1"
    
    # Check for [default] section
    if ! echo "$input" | grep -q '^\[default\]$'; then
        return 1
    fi
    
    # Check for required fields
    if ! echo "$input" | grep -qE '^client_secret\s*='; then
        return 1
    fi
    
    if ! echo "$input" | grep -qE '^host\s*='; then
        return 1
    fi
    
    if ! echo "$input" | grep -qE '^access_token\s*='; then
        return 1
    fi
    
    if ! echo "$input" | grep -qE '^client_token\s*='; then
        return 1
    fi
    
    return 0
}

# Main logic

if [[ "$QUIET_MODE" == true ]]; then
    # Quiet mode: just check and exit
    if [[ -f "$EDGERC_FILE" ]] && validate_edgerc "$EDGERC_FILE"; then
        echo -e "${GREEN}✓ Found valid .edgerc file at: $EDGERC_FILE${NC}"
        exit 0
    else
        echo ".edgerc file does not exist or invalid format"
        echo "Please copy and paste your.edgerc configuration into $EDGERC_FILE"
        echo "Expected format:"
        echo ""
        echo "[default]"
        echo "client_secret = your_client_secret"
        echo "host = your_akamai_host"
        echo "access_token = your_access_token"
        echo "client_token = your_client_token"
        exit 1
    fi
fi

# Interactive mode
echo "Checking for Akamai .edgerc configuration..."
echo ""

if [[ -f "$EDGERC_FILE" ]] && validate_edgerc "$EDGERC_FILE"; then
    # File exists and is valid
    echo -e "${GREEN}✓ Found valid .edgerc file at: $EDGERC_FILE${NC}"
    echo ""
    echo "----- File Content -----"
    cat "$EDGERC_FILE"
    echo "------------------------"
    echo ""
    read -p "Press Enter to exit..."
    exit 0
else
    # File doesn't exist or is invalid
    if [[ ! -f "$EDGERC_FILE" ]]; then
        echo -e "${YELLOW}⚠ .edgerc file not found at: $EDGERC_FILE${NC}"
    else
        echo -e "${YELLOW}⚠ .edgerc file exists but has invalid format at: $EDGERC_FILE${NC}"
    fi
    echo ""
    echo "Please copy and paste your .edgerc configuration below."
    echo "Expected format:"
    echo ""
    echo "[default]"
    echo "client_secret = your_client_secret"
    echo "host = your_akamai_host"
    echo "access_token = your_access_token"
    echo "client_token = your_client_token"
    echo ""
    echo "Paste your configuration (press Ctrl+D or type 'END' on a new line when done):"
    echo ""

    # Read multi-line input
    user_input=""
    while IFS= read -r line; do
        if [[ "$line" == "END" ]]; then
            break
        fi
        user_input+="$line"$'\n'
    done

    # Validate the input
    if validate_input "$user_input"; then
        # Create directory if it doesn't exist
        mkdir -p "$(dirname "$EDGERC_FILE")"

        # Save the configuration
        echo -n "$user_input" > "$EDGERC_FILE"
        chmod 600 "$EDGERC_FILE"

        echo ""
        echo -e "${GREEN}✓ Configuration saved successfully to: $EDGERC_FILE${NC}"
        echo ""
        read -p "Press Enter to exit..."
        exit 0
    else
        echo ""
        echo -e "${RED}✗ Invalid configuration format!${NC}"
        echo "The configuration must include:"
        echo "  - [default] section header"
        echo "  - client_secret field"
        echo "  - host field"
        echo "  - access_token field"
        echo "  - client_token field"
        echo ""
        read -p "Press Enter to exit..."
        exit 1
    fi
fi
