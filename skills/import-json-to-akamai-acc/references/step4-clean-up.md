# Workflow Step 4: Clean Up

This document covers mandatory cleanup after JSON import.

---

## Step 4: Clean Up (MANDATORY - DO NOT SKIP)

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
