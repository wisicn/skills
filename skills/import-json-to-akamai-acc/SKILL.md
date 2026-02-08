---
name: import-json-to-akamai-acc
description: This skill imports an Akamai Property Manager configuration file (JSON) into Akamai Control Center (ACC) using Akamai CLI. This skill should be used when users ask to "import json to akamai", "import json to akamai acc", "upload property JSON to Akamai", "import Akamai property JSON", or "apply JSON config to Akamai property".
---

# Import JSON to Akamai ACC

## Purpose

This skill imports an Akamai Property Manager configuration file (JSON) exported from another ACC account into the user's ACC **for review/reference only**. It does **not** add hostnames or activate the property.

## ⚠️ MANDATORY PRE-FLIGHT - READ ALL REFERENCES FIRST

> **CRITICAL: READ EACH REFERENCE FILE BEFORE EXECUTING ANY STEP**
>
> This workflow references detailed instruction files in the `references/` directory.
> **You MUST read EVERY referenced file BEFORE executing the corresponding workflow step.**
>
> These reference files contain **mandatory prerequisites, exact command sequences, and critical details** NOT fully documented in this high-level overview.
> **DO NOT rely solely on this workflow summary - always read the referenced files first.**
>
> **LANGUAGE RULE: Always use English when interacting with the user; NEVER translate to any other language.**

## Pre-requirements (manual)

Requirements: ACC credentials with PAPI client, valid contract, and a source (golden) property. See [references/prerequisites.md](references/prerequisites.md) for details.

## Workflow (follow in order)

### 1) **Explain the purpose + prerequisites**

Display the Purpose and Pre-requirements sections, then run `scripts/info_and_setup_source_property.sh` to configure the source property. See [references/step1-source-property.md](references/step1-source-property.md) for detailed instructions.

### 2) **Set up Akamai CLI and credentials**

Install and configure the Akamai CLI, set up `.edgerc` credentials, and verify the configuration. See [references/step2-akamai-cli-setup.md](references/step2-akamai-cli-setup.md) for detailed instructions.

### 3) **Import JSON to property**

- 3.1 Collect JSON input (file path or URL)
- 3.2 **MANDATORY**: Normalize with prepare-json.sh ⚠️ DO NOT SKIP
- 3.3 Import to destination property

See [references/step3-import-process.md](references/step3-import-process.md) for detailed instructions.

### 4) **Clean up temporary files**

Clean up temporary files after import. See [references/step4-clean-up.md](references/step4-clean-up.md) for detailed instructions.

## Inputs you must request
- Source property name (set in step 1; default `ai-agent-example`)
- Valid `.edgerc` `[default]` section
- JSON file content or path
- Destination property name

## Output
- New Akamai property created from the source property and updated with the JSON config.
- No activation or hostname setup is performed.

## Forbidden Actions (DO NOT DO THESE)
- Do NOT read/parse JSON files (validate path only)
- Do NOT run manual akamai CLI commands beyond specified scripts
- Do NOT skip reading reference/*.md files
- Do NOT deviate from the exact workflow in reference files

## Notes
- Always follow script output. Do not skip validation steps.
- **Preserve and show all script prompts and outputs verbatim** to the user (inputs requested by scripts + their printed output). This is mandatory for every script in this workflow, and especially important for `scripts/info_and_setup_source_property.sh`.
- **Treat the scripts as the source of truth, not the Akamai CLI output.** If a script reports success, ignore contradictory Akamai CLI output (e.g., `scripts/import_property.sh` final success message overrides noisy CLI output).
- Abort on any blocking error and ask the user to fix the environment before retrying.
