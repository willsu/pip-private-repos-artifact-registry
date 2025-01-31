#!/bin/bash
set -euo pipefail

# e.g. PIP_REPO=my-pip-repo
# e.g. PIP_HOST=us-central1-python.pkg.dev/my-project-id

SCRIPT_PATH=$(dirname "$(realpath "$0")")

PATH=${PATH}:/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin

# Use the access token from the currently authorized user (by default, the attached Service Account).
ACCESS_TOKEN="$(gcloud auth print-access-token)"

# Build the credentials to embed in the "index-url" for pip
USER_CREDENTIALS="oauth2accesstoken:${ACCESS_TOKEN}"

TMP_DIR=$(mktemp -d)
echo "Temp Dir Created: ${TMP_DIR}"
pushd $TMP_DIR

# Download keyring and dependencies
pip download keyring keyrings.google-artifactregistry-auth

# Install twine to upload packages
pip install twine

# Find all .whl files in current directory and upload the packages to Artifact Registry
find . -maxdepth 1 -name "*.whl" \
| while read -r PIP_PKG ; do
    python3 -m twine upload \
      --repository-url "https://${USER_CREDENTIALS}@${PIP_HOST}/${PIP_REPO}/" ${PIP_PKG}
  done

echo "Upload to ${PIP_HOST}/${PIP_REPO} Successful"

popd
