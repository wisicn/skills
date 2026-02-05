#!/bin/bash

set -e

# Display help message
cat << 'EOF'
This Agent Skill allows you to import an Akamai Property Manager configuration file (in JSON format) that was exported from another user's Akamai Control Center (ACC) into your own ACC. This is intended for review and reference purposes only — the import will not include subsequent steps such as adding hostnames or activating the property.

Here are the pre-requirements — all manual steps to be completed by you or your ACC administrator:

1. You have valid ACC login credentials and have already set up your PAPI client as instructed in the EdgeGrid documentation: https://techdocs.akamai.com/developer/docs/edgegrid

2. Your ACC must have a valid contract containing a series of Akamai products.

3. A golden example property must exist in your Akamai contract and group. In the Akamai PAPI workflow, new properties can only be created by copying an existing property as the source. The newly created property will be in the same contract and group as the golden example property. Typically, your ACC administrator has already created this and named it ai-agent-example as a generic source property.

4. If you need to place the imported property in a specific contract/group, you should create your own source property in that group. Don't worry — simply create an Akamai property with default values, as the source property's content doesn't matter; any property created from it will be updated with your provided JSON file.

EOF

GOLDEN_FILE="$HOME/.acc_golden_example"

# Function to validate if string is one line without any space
is_valid_source_property() {
    local str="$1"
    # Check if it's one line (no newlines) and contains no spaces
    if [[ "$str" =~ ^[^[:space:]]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Check if the golden file exists
if [[ -f "$GOLDEN_FILE" ]]; then
    # Read the content
    content=$(cat "$GOLDEN_FILE")
    
    # Validate: one line string without any space
    if is_valid_source_property "$content"; then
        echo ""
        read -rp "Press Enter to use existing source property '$content', or input a new one: " user_input
        
        # If user just pressed Enter, use existing value
        if [[ -z "$user_input" ]]; then
            ACC_SOURCE_FILE="$content"
            exit 0
        fi
        
        # Validate the new input
        if is_valid_source_property "$user_input"; then
            ACC_SOURCE_FILE="$user_input"
            echo "$ACC_SOURCE_FILE" > "$GOLDEN_FILE"
            echo "Source property '$ACC_SOURCE_FILE' has been saved as your default."
            exit 0
        else
            echo "Error: Invalid property name. It must be a single word without spaces." >&2
            exit 1
        fi
    fi
fi

# File doesn't exist or invalid content - prompt user
echo ""
read -rp "Enter the source property name [default: ai-agent-example]: " user_input

# If user just pressed Enter, use default
if [[ -z "$user_input" ]]; then
    user_input="ai-agent-example"
fi

# Validate the input
if is_valid_source_property "$user_input"; then
    ACC_SOURCE_FILE="$user_input"
    echo "$ACC_SOURCE_FILE" > "$GOLDEN_FILE"
    echo "Source property '$ACC_SOURCE_FILE' has been saved as your default."
    exit 0
else
    echo "Error: Invalid property name. It must be a single word without spaces." >&2
    exit 1
fi
