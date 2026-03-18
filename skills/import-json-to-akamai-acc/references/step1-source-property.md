# Workflow Step 1: Explain Purpose and Prerequisites

## Overview

Display the SKILL.md's **Purpose** and **Pre-requirements (manual)** sections to the user, then configure the source property.

## Steps

1. Run `scripts/info_and_setup_source_property.sh -q` to check if a valid source property is already configured.
   - The script **always** prints the pre-requirements info block first, regardless of flags.
   - In quiet mode (`-q`), it then checks whether `$HOME/.acc_golden_example` exists and contains a valid value.
2. If the `-q` check exits with code `0`, the source property is already configured — proceed to Step 2 of the workflow.
3. If the `-q` check exits with a non-zero code (file missing or invalid content), ask the user to provide a source property name (default: `ai-agent-example`), then run `scripts/info_and_setup_source_property.sh -s <user-input-name>` to save it.

## Script Prompts

The following are example outputs for each scenario. These are illustrative examples for the AI Agent — not real values.

### `-q` (quiet check) — success
```
<pre-requirements info block printed here>
Validate successful. Using existing source property: <some-valid-string> in your /Users/yourname/.acc_golden_example
```
Exit code: `0`

### `-q` (quiet check) — file does not exist
```
<pre-requirements info block printed here>
Error: /path/to/home/.acc_golden_example does not exist.
Please create it with: ./info_and_setup_source_property.sh -s ai-agent-example
```
Exit code: `1`

### `-q` (quiet check) — file exists but contains invalid content
```
<pre-requirements info block printed here>
Error: Invalid value in /path/to/home/.acc_golden_example.
Please set it with: ./info_and_setup_source_property.sh -s ai-agent-example
```
Exit code: `1`

### `-s <name>` (setup) — success
```
<pre-requirements info block printed here>
Source property '<name>' has been saved in '/path/to/home/.acc_golden_example' as your default.
```
Exit code: `0`

### `-s <name>` (setup) — invalid name
```
<pre-requirements info block printed here>
Error: Invalid property name '<name>'. It must be a single word without spaces.
```
Exit code: `1`

## Validation Rules

- The property name **must be a single word with no spaces**
- Invalid input produces: `Error: Invalid property name. It must be a single word without spaces.`

## Important Notes

- In chat, **do not ask the user to press Enter**. Ask them to reply with the source property name (or confirm the default `ai-agent-example`) in their next message, then continue.
- If the user has not met prerequisites (valid PAPI client, contract/group, source property), stop and ask them to complete them **before** continuing.
- Always show the full script output verbatim to the user, including the pre-requirements info block.
