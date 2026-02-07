---
name: import-json-to-akamai-acc
description: This skill imports an Akamai Property Manager configuration file (JSON) into Akamai Control Center (ACC) using Akamai CLI. This skill should be used when users ask to "import json to akamai", "import json to akamai acc", "upload property JSON to Akamai", "import Akamai property JSON", or "apply JSON config to Akamai property".
---

# Import JSON to Akamai ACC

## Purpose

This skill imports an Akamai Property Manager configuration file (JSON) exported from another ACC account into the user's ACC **for review/reference only**. It does **not** add hostnames or activate the property.

## Pre-requirements (manual)

Requirements: ACC credentials with PAPI client, valid contract, and a source (golden) property. See [references/prerequisites.md](references/prerequisites.md) for details.

## Workflow (follow in order)

### 1) **Explain the purpose + prerequisites**
- Display the SKILL.md's **Purpose** and **Pre-requirements (manual)** sections to the user.
- Run `scripts/info_and_setup_source_property.sh`.
- The script prints the pre-requirements above and then asks for a **source property** name.
- The chosen source property is saved to `~/.acc_golden_example` for reuse.
- The script may prompt in one of two ways:
  - If a saved source property exists: `Press Enter to use existing source property '<value>', or input a new one:`
  - Otherwise: `Enter the source property name [default: ai-agent-example]:`
- The property name **must be a single word with no spaces**. Invalid input produces: `Error: Invalid property name. It must be a single word without spaces.`
- In chat, **do not ask the user to press Enter**. Ask them to reply with the source property name (or confirm the default) in their next message, then continue.
- If the user has not met prerequisites (valid PAPI client, contract/group, source property), stop and ask them to complete them **before** continuing.

### 2) **Verify Akamai CLI availability**
- Run `scripts/verify_akamai_cli_executable.sh`.
- If it fails, run `scripts/install_akamai_cli.sh`, then re-run `scripts/verify_akamai_cli_executable.sh`.
- If the scripts take a long time to run, inform the user that the Akamai CLI is still being installed and ask them to wait.
- If install fails, stop and report the error.

### 3) Configure `.edgerc`

  #### Step 3.1: Initial Validation

  * The agent MUST execute:

    ```bash
    scripts/check_edgerc.sh -q
    ```

  * **IF** the command exits successfully (exit code `0`):

    * The agent MUST proceed to the next step in the workflow.
    * The agent MUST NOT prompt the user for `.edgerc` content.



  #### Step 3.2: Failure Handling

  * **IF** the command exits with a non-zero exit code:

    * The agent MUST display the following example to the user **before** requesting any credentials:

      ```ini
      [default]
      client_secret = your_client_secret
      host = your_akamai_host
      access_token = your_access_token
      client_token = your_client_token
      ```

    * The agent MUST instruct the user to:

      * Paste the **entire `[default]` block**
      * Matching the format shown above


  #### Step 3.3: Writing `.edgerc`

  * **ONLY IF** all required elements are present:

    * The agent MUST confirm receipt using a minimal acknowledgment (e.g. `Received`).
    * The agent MUST write the user-provided content to:

      ```
      $HOME/.edgerc
      ```
    * The agent MUST rewrite the content into a multi-line INI format that matches the display example shown to the user in previous instructions.




  #### Step 3.4: Re-validation

  * After writing the file, the agent MUST re-run:

    ```bash
    scripts/check_edgerc.sh -q
    ```

  * **IF** the command exits successfully:

    * The agent MUST proceed with the workflow.

  * **IF** the command exits with a non-zero exit code:

    * The agent MUST stop.
    * The agent MUST instruct the user to fix the `.edgerc` credentials.
    * The agent MUST NOT attempt further retries or auto-corrections.



  #### Forbidden Actions (Hard Constraints)

  The agent MUST NOT:

  * Infer, fabricate, or auto-generate `.edgerc` values
  * Merge with existing `.edgerc` content
  * Proceed if credential validation fails

### 4) **Verify Akamai CLI config + property-manager package**
- Run `scripts/verify_akamai_cli_config.sh`.
- If the scripts take a long time to run, inform the user that the Akamai CLI is still being installed and ask them to wait.
- If it fails, this is **a blocking issue**. Stop, show the output, and ask the user to fix credentials/network and restart from step 1.

### 5) **Collect JSON input**
- Prompt the user to supply either:
  - A local file path to the JSON file, or
  - A downloadable URL accessible by the AI agent.
- If a URL is provided, download the file and save it to a temporary location such as `/tmp/akamai-import.json`.
- **Important:** Instruct users **not** to copy/paste JSON content into chat. Explain that large JSON files consume excessive tokens and may be truncated.
- Keep the file path in a variable like `JSON_PATH`.

### 6) **Normalize JSON**
- Run `scripts/prepare-json.sh "$JSON_PATH"`.
- This requires `jq`.
  - If `jq` is missing, attempt to install it (`apt-get`, `brew`, etc.).
  - If install fails, stop and tell the user to install `jq` manually, then restart.
- If `prepare-json.sh` fails, stop and delete the file at `JSON_PATH`.

### 7) **Import to destination property**
- Ask the user for the **destination property name** (must be one word, no spaces).
- Run `scripts/import_property.sh "$JSON_PATH" "$DEST_PROPERTY"`.
- If it fails:
  - Report the error and stop.
  - Delete `JSON_PATH`.
  - Tell the user to remove the partially created destination property in Akamai ACC if it exists.
- If the script succeeds, ignore the Akamai CLI's output message and **do not ask the user if they want to do anything else**. Proceed directly to cleanup.

### 8) **Clean up**
- Delete the `snippets-logs.log` inside the skill directory if it exists.
- Delete `JSON_PATH` if it still exists.

## Inputs you must request
- Source property name (set in step 1; default `ai-agent-example`)
- Valid `.edgerc` `[default]` section
- JSON file content or path
- Destination property name

## Output
- New Akamai property created from the source property and updated with the JSON config.
- No activation or hostname setup is performed.

## Notes
- Always use English when interacting with the user; **never** translate to any other language.
- Always follow script output. Do not skip validation steps.
- **Preserve and show all script prompts and outputs verbatim** to the user (inputs requested by scripts + their printed output). This is mandatory for every script in this workflow, and especially important for `scripts/info_and_setup_source_property.sh`.
- **Treat the scripts as the source of truth, not the Akamai CLI output.** If a script reports success, ignore contradictory Akamai CLI output (e.g., `scripts/import_property.sh` final success message overrides noisy CLI output).
- Abort on any blocking error and ask the user to fix the environment before retrying.
