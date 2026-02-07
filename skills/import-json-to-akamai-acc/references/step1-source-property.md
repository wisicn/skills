# Workflow Step 1: Explain Purpose and Prerequisites

## Overview

Display the SKILL.md's **Purpose** and **Pre-requirements (manual)** sections to the user, then configure the source property.

## Steps

1. Run `scripts/info_and_setup_source_property.sh`
2. The script prints the pre-requirements and asks for a **source property** name
3. The chosen source property is saved to `~/.acc_golden_example` for reuse

## Script Prompts

The script may prompt in one of two ways:

- If a saved source property exists:
  ```
  Press Enter to use existing source property '<value>', or input a new one:
  ```

- Otherwise:
  ```
  Enter the source property name [default: ai-agent-example]:
  ```

## Validation Rules

- The property name **must be a single word with no spaces**
- Invalid input produces: `Error: Invalid property name. It must be a single word without spaces.`

## Important Notes

- In chat, **do not ask the user to press Enter**. Ask them to reply with the source property name (or confirm the default) in their next message, then continue.
- If the user has not met prerequisites (valid PAPI client, contract/group, source property), stop and ask them to complete them **before** continuing.
