#!/bin/bash

# import_property.sh - Import Akamai property JSON file to ACC
# Usage: ./import_property.sh <json_file> <property_name>

set -e

JSON_FILE="$1"
PROPERTY_NAME="$2"

if [ $# -ne 2 ]; then
    echo "Error: JSON file path and property name are required"
    echo "Usage: $0 <json_file> <property_name>"
    exit 1
fi

GOLDEN_FILE="$HOME/.acc_golden_example"

# Function to validate if string is one line without any space
is_valid_source_property() {
    local str="$1"
    if [[ "$str" =~ ^[^[:space:]]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Get source property name from golden file or prompt
if [[ -f "$GOLDEN_FILE" ]]; then
    content=$(cat "$GOLDEN_FILE")
    if is_valid_source_property "$content"; then
        SOURCE_PROPERTY_NAME="$content"
    fi
fi

# If no valid source property from file, prompt user
if [[ -z "$SOURCE_PROPERTY_NAME" ]]; then
    echo ""
    read -rp "Enter the source property name [default: ai-agent-example]: " user_input
    if [[ -z "$user_input" ]]; then
        user_input="ai-agent-example"
    fi
    if is_valid_source_property "$user_input"; then
        SOURCE_PROPERTY_NAME="$user_input"
    else
        echo "Error: Invalid property name. It must be a single word without spaces." >&2
        exit 1
    fi
fi

if [ ! -f "$JSON_FILE" ]; then
    echo "Error: JSON file '$JSON_FILE' does not exist"
    exit 1
fi

#AKAMAI_CMD="/usr/local/bin/akamai"
AKAMAI_CMD="akamai"

echo "Starting Akamai property import..."
echo "JSON file: $JSON_FILE"
echo "Property name: $PROPERTY_NAME"
echo "Source property name: $SOURCE_PROPERTY_NAME"
echo

# Step 1: Create new property
echo "Step 1: Creating new property..."
echo "Executing: $AKAMAI_CMD --section default pm new-property --nolocaldir -e $SOURCE_PROPERTY_NAME -n 1 --property $PROPERTY_NAME"
"$AKAMAI_CMD" --section default pm new-property --nolocaldir -e "$SOURCE_PROPERTY_NAME" -n 1 --property "$PROPERTY_NAME"

if [ $? -eq 0 ]; then
    echo "✓ Successfully created property: $PROPERTY_NAME"
    echo "✓ sleep 15 seconds after created property: $PROPERTY_NAME"
    sleep 15
else
    echo "✗ Failed to create property"
    exit 1
fi

# Step 2: Update property configuration
echo "Step 2: Updating property configuration..."
JSON_FILENAME=$(basename "$JSON_FILE")
CURRENT_DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
echo "Executing: $AKAMAI_CMD --section default pm property-update --file $JSON_FILE -p $PROPERTY_NAME --propver 1 --message \"update with $JSON_FILENAME at $CURRENT_DATETIME\""
"$AKAMAI_CMD" --section default pm property-update --file "$JSON_FILE" -p "$PROPERTY_NAME" --propver 1 --message "update with $JSON_FILENAME at $CURRENT_DATETIME"

#echo "Executing: $AKAMAI_CMD --section default pm delete -p $PROPERTY_NAME --force-delete"

if [ $? -eq 0 ]; then
    echo "✓ Successfully imported JSON configuration to property: $PROPERTY_NAME"
else
    echo "✗ Failed to import JSON configuration, check the JSON file, remove the advanced metada from the JSON file"
    echo "Executing: $AKAMAI_CMD --section default pm delete -p $PROPERTY_NAME --force-delete"
    "$AKAMAI_CMD" --section default pm delete -p "$PROPERTY_NAME" --force-delete
    exit 1
fi



echo "✅ Akamai property import completed!"
echo "Property name: $PROPERTY_NAME"
echo "JSON file: $JSON_FILE"

