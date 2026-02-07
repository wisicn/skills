# Prerequisites for Importing JSON to Akamai ACC

## Purpose

This skill imports an Akamai Property Manager configuration file (JSON) exported from another ACC account into your own ACC **for review/reference only**. It does **not** add hostnames or activate the property.

## Pre-requirements (manual)

These are mandatory and must be completed before running the workflow:

1. **Valid ACC login credentials and configured PAPI client (EdgeGrid)**
   - Setup guide: https://techdocs.akamai.com/developer/docs/edgegrid

2. **Valid contract in ACC**
   - Your ACC must have a valid contract containing Akamai products.

3. **Source (golden) property in the correct contract/group**
   - New properties are created by copying an existing property in the same contract/group.
   - Common default name: `ai-agent-example`
   - If the imported property must live in a specific contract/group, create a source property **in that group** first.
   - The source property's contents do not matter; it will be overwritten by the JSON import.
