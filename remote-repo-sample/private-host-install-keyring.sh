#!/bin/bash
set -euo pipefail

# e.g. PIP_REPO=my-pip-repo
# e.g. PIP_HOST=us-central1-python.pkg.dev/my-project-id

# Add pre-installed pip executable to path
PATH=${PATH}:/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin

# Use the access token from the currently authorized user (by default, the attached Service Account).
ACCESS_TOKEN="$(gcloud auth print-access-token)"

# Build the credentials to embed in the "index-url" for pip
USER_CREDENTIALS="oauth2accesstoken:${ACCESS_TOKEN}"

# Install required keyring libraries to access private Artifact Registry repositories
pip install keyring keyrings.google-artifactregistry-auth \
  --index-url="https://${USER_CREDENTIALS}@${PIP_HOST}/${PIP_REPO}/simple/"

echo "Success: Keyring and keyrings.google-artifactregistry-auth installed."
echo "Next: Run ./configure-pip-env.sh to configure your local environment"
echo "Note: Change the \"PIP_REPO\" var if you plan to pull private packages from a different directory"
