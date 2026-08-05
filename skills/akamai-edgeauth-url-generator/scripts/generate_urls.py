#!/usr/bin/env python3
"""
Akamai EdgeAuth URL Batch Generator

Reads a CSV file containing URL paths and generates signed Akamai EdgeAuth URLs.

Usage:
    python3 generate_urls.py <csv_file> [--key KEY] [--token-name NAME] [--end-time EPOCH] [--domain DOMAIN] [--output OUTPUT]

    Example:
        python3 generate_urls.py ./urlpath.csv \
            --key 123abcyourpasskeyexamplestring \
            --token-name your_token \
            --end-time 1790764816 \
            --domain cdn.example.com \
            --output fullURL.txt
"""

import argparse
import csv
import os
import sys


def find_cms_edgeauth_script():
    """Locate cms_edgeauth.py next to this script."""
    script_dir = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(script_dir, "cms_edgeauth.py")
    if os.path.isfile(path):
        return path
    return None


def main():
    parser = argparse.ArgumentParser(description="Batch generate Akamai EdgeAuth signed URLs from a CSV file.")
    parser.add_argument("csv_file", help="Path to the CSV file containing URL paths (second column).")
    parser.add_argument("--key", required=True, help="Akamai EdgeAuth secret key (hex string).")
    parser.add_argument("--token-name", default="your_token", help="Token parameter name. Default: your_token")
    parser.add_argument("--end-time", required=True, help="Token expiration time (Unix epoch).")
    parser.add_argument("--domain", required=True, help="Base domain for the final URLs.")
    parser.add_argument("--output", default="fullURL.txt", help="Output file path. Default: fullURL.txt")
    parser.add_argument("--auth-script", help="Path to cms_edgeauth.py. Auto-detected if not provided.")

    args = parser.parse_args()

    # Locate and import the EdgeAuth module
    auth_script = args.auth_script or find_cms_edgeauth_script()
    if not auth_script:
        print("Error: Could not find cms_edgeauth.py. Please specify --auth-script.", file=sys.stderr)
        sys.exit(1)

    auth_dir = os.path.dirname(auth_script)
    if auth_dir and auth_dir not in sys.path:
        sys.path.insert(0, auth_dir)

    try:
        from cms_edgeauth import EdgeAuth
    except ImportError as e:
        print(f"Error importing EdgeAuth from {auth_script}: {e}", file=sys.stderr)
        sys.exit(1)

    auth = EdgeAuth(
        token_name=args.token_name,
        key=args.key,
        algorithm="sha256",
        end_time=args.end_time,
        escape_early=True,
    )

    urls = []
    with open(args.csv_file, "r", encoding="utf-8") as f:
        reader = csv.reader(f)
        try:
            next(reader)  # skip header
        except StopIteration:
            print("Error: CSV file is empty.", file=sys.stderr)
            sys.exit(1)

        for row in reader:
            if len(row) >= 2:
                url_path = row[1].strip()
                if url_path:
                    token = auth.generate_url_token(url_path)
                    full_url = f"https://{args.domain}{url_path}?{args.token_name}={token}"
                    urls.append(full_url)

    with open(args.output, "w", encoding="utf-8") as f:
        for url in urls:
            f.write(url + "\n")

    print(f"Done! Generated {len(urls)} URLs in {args.output}")


if __name__ == "__main__":
    main()

