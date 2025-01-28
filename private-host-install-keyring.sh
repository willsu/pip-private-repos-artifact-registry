#!/bin/bash
set -exuo pipefail

# e.g. PIP_REPO=my-pip-repo
# e.g. REGION=us-central1

# Add pre-installed pip executable to path
PATH=${PATH}:/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin

TMP_DIR=$(mktemp -d)
echo "Temp Dir Created: ${TMP_DIR}"
pushd $TMP_DIR

# Download all keyring and keyrings.google_artifactregistry-auth dependencies
ALL_PKGS=( $(gcloud artifacts files list \
             --repository=${PIP_REPO} \
             --location=${REGION} | tail -n +2 | awk '{print $1}') )

for PKG_FULL_NAME in "${ALL_PKGS[@]}"; do

  if [ ! -z ${PKG_FULL_NAME} ]; then
    gcloud artifacts files download \
      --location=${REGION} \
      --repository=${PIP_REPO} \
      --destination=. \
      $PKG_FULL_NAME
  else
    echo "The PIP package: ${KEYRING_PKG} could not be found. Please verify that it exists in the repository"
    exit 1
  fi

  # The actual file will be downloaded with an encoded "/" as "%2F"
  PKG_FILE_NAME="$(echo $PKG_FULL_NAME | sed 's/\//%2F/g')"
  # Truncate everything up to the encoded "/" ("%2F") for ease of package installation
  PKG_SHORT_NAME="$(echo $PKG_FILE_NAME | sed 's/.*%2F//g')"
  # Rename the file to the truncated version
  mv $PKG_FILE_NAME $PKG_SHORT_NAME

done

# Install required keyring libraries to access private Artifact Registry repositories
pip install --no-index --find-links . keyring
pip install --no-index --find-links . keyrings.google_artifactregistry-auth

popd
