#!/bin/bash

# Check if input file is provided
if [ $# -lt 1 ]; then
    echo "Usage: $0 <input-json-file> [output-json-file]"
    echo "Example: $0 input.json output.json"
    echo "         (if output file not specified, will overwrite input file)"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FILE="${2:-$INPUT_FILE}"

# Check if input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found."
    exit 1
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed. Please install jq first."
    echo "  macOS: brew install jq"
    echo "  Ubuntu/Debian: sudo apt-get install jq"
    echo "  CentOS/RHEL: sudo yum install jq"
    exit 1
fi

# Use jq to:
# 1. Recursively walk through JSON and delete all "advancedOverride" keys
# 2. Remove all behaviors where "name" == "advanced"
# 3. Remove read-only behaviors: "dnsPrefresh"
# 4. Remove read-only criteria: "matchAdvanced"
jq '
def remove_readonly_elements:
    walk(
        if type == "object" then
            # Remove advancedOverride key
            del(.advancedOverride)
            | # Filter out behaviors with name == "advanced" or read-only behaviors
            if has("behaviors") and (.behaviors | type == "array") then
                .behaviors = [.behaviors[] | select(.name != "advanced" and .name != "dnsPrefresh")]
            else
                .
            end
            | # Filter out criteria/matches with name == "matchAdvanced"
            if has("criteria") and (.criteria | type == "array") then
                .criteria = [.criteria[] | select(.name != "matchAdvanced")]
            else
                .
            end
            | # Also check for "match" field (alternative criteria structure)
            if has("match") and (.match | type == "object") and (.match.name == "matchAdvanced") then
                del(.match)
            else
                .
            end
        else
            .
        end
    );
remove_readonly_elements' "$INPUT_FILE" > "${OUTPUT_FILE}.tmp"

# Check if jq succeeded
if [ $? -eq 0 ]; then
    mv "${OUTPUT_FILE}.tmp" "$OUTPUT_FILE"
    echo "Successfully removed all 'advancedOverride' fields."
    echo "Output saved to: $OUTPUT_FILE"
else
    rm -f "${OUTPUT_FILE}.tmp"
    echo "Error: Failed to process JSON file."
    exit 1
fi
