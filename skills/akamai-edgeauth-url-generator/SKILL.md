---
name: akamai-edgeauth-url-generator
description: >
  This skill generates Akamai EdgeAuth signed URLs from a CSV file containing URL paths.
  It should be used when the user needs to batch-process URL paths in a CSV file to produce
  full URLs with Akamai EdgeAuth query-string tokens (e.g., `your_token=exp=...~hmac=...`).
  Trigger phrases include: "generate fullURL", "create fullURL.txt", "Akamai token URL",
  "sign URLs with EdgeAuth", or when the user provides a CSV file with URL paths and asks
  for signed URLs.
---

# Akamai EdgeAuth URL Generator

## Overview

Automate the batch generation of Akamai EdgeAuth signed URLs from a CSV file.
Given a CSV where the second column contains URL paths, this skill produces a text file
containing one full HTTPS URL per line, appended with the generated EdgeAuth token.

## Workflow

### 1. Gather Required Parameters

Before execution, confirm the following parameters with the user (or infer from context):

- **CSV file path**: The input CSV (e.g., `./urlpath.csv`). The second column must contain the URL paths.
- **KEY**: Akamai secret key (hexadecimal string).
- **TOKEN_NAME**: Query parameter name for the token (default: `your_token`).
- **END_TIME**: Token expiration time as Unix epoch (e.g., `1790764816`).
- **DOMAIN**: Base domain prepended to each URL path (e.g., `cdn.example.com`).
- **cms_edgeauth.py path** (optional): Path to the [Akamai provided](https://github.com/akamai/EdgeAuth-Token-Python/blob/master/cms_edgeauth.py) `cms_edgeauth.py` script. If omitted, the script uses the bundled `cms_edgeauth.py` in the same folder as `generate_urls.py`.

### 2. Execute the Batch Script

Run the bundled Python script to generate the signed URLs:

```bash
python3 ./skills/akamai-edgeauth-url-generator/scripts/generate_urls.py \
  <csv_file> \
  --key <KEY> \
  --token-name <TOKEN_NAME> \
  --end-time <END_TIME> \
  --domain <DOMAIN> \
  --output <output_file>
```

Example:

```bash
python3 ./skills/akamai-edgeauth-url-generator/scripts/generate_urls.py \
  ./urlpath.csv \
  --key 123abcyourpasskeyexamplestring \
  --token-name your_token \
  --end-time 1790764816 \
  --domain cdn.example.com \
  --output fullURL.txt
```

### 3. Verify Output

After execution, confirm that the output file (default `fullURL.txt`) exists and contains
the expected number of lines. Each line should follow this format:

```
https://<DOMAIN><URL_PATH>?<TOKEN_NAME>=exp=<END_TIME>~hmac=<HMAC>
```

### 4. Report Results

Inform the user of the output file path and the number of URLs generated.

## Script Reference

- `scripts/generate_urls.py` — Main batch-processing script.
  - Reads the input CSV (skipping the header).
  - Imports `EdgeAuth` from the user's `cms_edgeauth.py`.
  - Generates one signed URL per row and writes them to the output file.

## Notes

- The script assumes the CSV uses commas as delimiters and that the first row is a header.
- The `EdgeAuth` class is instantiated with `escape_early=True` and `algorithm="sha256"`,
  matching the standard Akamai EdgeAuth CLI behavior (`-x` flag).
- By default, `cms_edgeauth.py` is loaded from the same folder as `generate_urls.py`.
  If you need to use a different copy, pass its absolute path via the `--auth-script` argument.
