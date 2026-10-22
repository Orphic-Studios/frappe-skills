#!/usr/bin/env bash
set -e

HERMES_DIR="${HOME}/.config/hermes/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

echo "Installing Frappe Skills Pack into Hermes..."
mkdir -p "${HERMES_DIR}"

cp -r "${REPO_ROOT}/frappe-docs" "${HERMES_DIR}/"
cp -r "${REPO_ROOT}/frappe-course-generator" "${HERMES_DIR}/"

echo "✓ Successfully installed frappe-docs and frappe-course-generator to ${HERMES_DIR}"
echo "You can now query Hermes with Frappe and ERPNext tasks."
