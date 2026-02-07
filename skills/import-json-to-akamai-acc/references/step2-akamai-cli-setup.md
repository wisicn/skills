# Workflow Steps 2 **Set up Akamai CLI and credentials**

This document covers the setup and configuration of Akamai CLI, credentials, and validation.

---

## Step 2.1: Verify Akamai CLI Availability

1. Run `scripts/verify_akamai_cli_executable.sh`
2. If it fails, run `scripts/install_akamai_cli.sh`, then re-run `scripts/verify_akamai_cli_executable.sh`
3. If the scripts take a long time to run, inform the user that the Akamai CLI is still being installed and ask them to wait
4. If install fails, stop and report the error

---

## Step 2.2: Configure `.edgerc`

### Step 2.2.1: Initial Validation

Execute:
```bash
scripts/check_edgerc.sh -q
```

**IF** the command exits successfully (exit code `0`):
- Proceed to the next step
- Do NOT prompt the user for `.edgerc` content

### Step 2.2.2: Failure Handling

**IF** the command exits with a non-zero exit code:

Display this example to the user **before** requesting credentials:
```ini
[default]
client_secret = your_client_secret
host = your_akamai_host
access_token = your_access_token
client_token = your_client_token
```

Instruct the user to:
- Paste the **entire `[default]` block**
- Match the format shown above

### Step 2.2.3: Writing `.edgerc`

**ONLY IF** all required elements are present:
- Confirm receipt using a minimal acknowledgment (e.g. `Received`)
- Write user-provided content to: `$HOME/.edgerc`
- Rewrite into multi-line INI format matching the display example

### Step 2.2.4: Re-validation

After writing the file, re-run:
```bash
scripts/check_edgerc.sh -q
```

**IF** successful: Proceed with the workflow  
**IF** failed: Stop and instruct user to fix credentials

### Forbidden Actions (Hard Constraints)

- Infer, fabricate, or auto-generate `.edgerc` values
- Merge with existing `.edgerc` content
- Proceed if credential validation fails

---

## Step 2.3: Verify Akamai CLI Config + Property-Manager Package

1. Run `scripts/verify_akamai_cli_config.sh`
2. If the scripts take a long time to run, inform the user that the Akamai CLI is still being installed and ask them to wait
3. If it fails, this is **a blocking issue**. Stop, show the output, and ask the user to fix credentials/network and restart from step 1
