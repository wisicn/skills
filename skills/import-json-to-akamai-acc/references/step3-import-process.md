# Workflow Step 3: JSON Import Process

This document covers collecting JSON input, normalizing it, importing to Akamai, and cleanup.


---

## Step 3.1: Collect JSON Input

**AGENT ACTION:** Ask the user for JSON input using this exact message:

> Please provide one of the following:
> 1. A local file path to the JSON file
> 2. A downloadable URL to the JSON file
>
> ⚠️ **Do NOT copy/paste JSON content directly** - large files consume excessive tokens and may be truncated.

**If URL provided:**
- Download the file
- Save to: `/tmp/akamai-import.json`
- Set `JSON_PATH="/tmp/akamai-import.json"`

**If local path provided:**
- Validate file exists
- Set `JSON_PATH` to the provided path

**NEXT STEP CHECKPOINT**: After setting `JSON_PATH`, you MUST proceed to Step 3.2. Do NOT skip to Step 3.3.

---

## Step 3.2: Normalize JSON (MANDATORY - DO NOT SKIP)

🚨 **CRITICAL**: This step is **MANDATORY**. The import WILL FAIL without this step.

**Execution:**
```bash
scripts/prepare-json.sh "$JSON_PATH"
```

### Requirements

This script requires `jq`. If `jq` is missing:
- Attempt to install it (`apt-get`, `brew`, etc.)
- If installation fails, stop and tell the user to install `jq` manually, then restart

**Validation - You MUST check:**
- [ ] Script executed without errors

### Error Handling

If `prepare-json.sh` fails:
- STOP immediately
- Do NOT proceed to Step 3.3
- Delete the file at `JSON_PATH`
- Report error to user


---

## Step 3.3: Import to Destination Property

⚠️ **PRE-CONDITION**: Step 3.2 must have completed successfully.

### 3.3.1 Get Destination Property Name

Ask the user for the **destination property name**:
- Must be one word
- No spaces allowed

### 3.3.2 Run Import Script

 qqq```bash
scripts/import_property.sh "$JSON_PATH" "$DEST_PROPERTY"
```

### 3.3.3 Error Handling

If the import fails:
1. Report the error and stop
2. Delete `JSON_PATH`
3. Tell the user to remove the partially created destination property in Akamai ACC if it exists

### 3.3.4 Success Handling

If the script succeeds:
- Ignore the Akamai CLI's output message
- **Do not ask the user if they want to do anything else**
- Proceed directly to cleanup

**NEXT STEP CHECKPOINT**: Proceed to Step 3.4 regardless of success/failure

---

## Step 3.4: Clean Up (MANDATORY - DO NOT SKIP)

🚨 **CRITICAL**: This step is **MANDATORY** even if previous steps failed.

**Important: This step is mandatory and must not be skipped, even if previous steps failed.** 
Delete temporary files:
- Delete `snippets-logs.log` inside the skill directory if it exists
- Delete `JSON_PATH` if it still exists

**Agent MUST execute:**
```bash
# Clean up temporary files
rm -f snippets-logs.log
rm -f "$JSON_PATH"
```

**Validation Checklist:**
- [ ] `snippets-logs.log` deleted (if exists)
- [ ] `JSON_PATH` file deleted

**DO NOT END CONVERSATION** until cleanup is confirmed complete.

### Error Handling
- report error to the user
- Tell the user to remove the `JSON_PATH` manually if it still exists

