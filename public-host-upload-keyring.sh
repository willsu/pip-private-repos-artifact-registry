#!/bin/bash
set -exuo pipefail

# e.g. PIP_REPO_BASE_URL=https://REGION-python.pkg.dev/PROJECT_ID
# e.g. PIP_REPO=my-pip-repo

SCRIPT_PATH=$(dirname "$(realpath "$0")")

PATH=${PATH}:/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin

TMP_DIR=$(mktemp -d)
echo "Temp Dir Created: ${TMP_DIR}"
pushd $TMP_DIR

# List of Artifact Registry keyring dependencies
KEYRING_PKGS=(
  "keyring"
  "keyrings.google-artifactregistry-auth"
)

for KEYRING_PKG in ${KEYRING_PKGS[@]}; do
  pip download $KEYRING_PKG
  pip install $KEYRING_PKG
done

# Install twine from pypi before configuring private Artifact Registry credentials
pip install twine

# Configure pip access to Artifact Registry
./"${SCRIPT_PATH}/configure-pip-env.sh"

mkdir -p ~/.pip
echo "$PYCONF" > $HOME/.pip/pip.conf

find . -maxdepth 1 -name "*.whl" \
| while read -r PIP_PKG ; do
    python3 -m twine upload \
      --repository-url "${PIP_REPO_BASE_URL}/${PIP_REPO}/" ${PIP_PKG}
  done

popd
