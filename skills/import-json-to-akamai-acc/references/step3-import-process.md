# Workflow Step 3: JSON Import Process

This document covers collecting JSON input, normalizing it, importing to Akamai, and cleanup.

---

## Step 3.1: Collect JSON Input

Prompt the user to supply either:
- A local file path to the JSON file, or
- A downloadable URL accessible by the AI agent

If a URL is provided:
- Download the file
- Save to a temporary location such as `/tmp/akamai-import.json`

**Important:** Instruct users **not** to copy/paste JSON content into chat. Explain that large JSON files consume excessive tokens and may be truncated.

Store the file path in a variable like `JSON_PATH`.

---

## Step 3.2: Normalize JSON

**Attention: This step is mandatory. Do not skip it even if you already have the destination property name.** Run the JSON preparation script:
```bash
scripts/prepare-json.sh "$JSON_PATH"
```


### Requirements

This script requires `jq`. If `jq` is missing:
- Attempt to install it (`apt-get`, `brew`, etc.)
- If installation fails, stop and tell the user to install `jq` manually, then restart

### Error Handling

If `prepare-json.sh` fails:
- Stop the workflow
- Delete the file at `JSON_PATH`

---

## Step 3.3: Import to Destination Property

### 3.3.1 Get Destination Property Name

Ask the user for the **destination property name**:
- Must be one word
- No spaces allowed

### 3.3.2 Run Import Script

Execute:
```bash
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

---

## Step 3.4: Clean Up
**Important: This step is mandatory and must not be skipped, even if previous steps failed.** 
Delete temporary files:
- Delete `snippets-logs.log` inside the skill directory if it exists
- Delete `JSON_PATH` if it still exists
