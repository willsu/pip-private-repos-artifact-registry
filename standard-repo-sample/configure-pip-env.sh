#!/bin/bash
set -euo pipefail

# e.g. PIP_REPO=my-pip-repo
# e.g. PIP_REPO_BASE_URL=https://REGION-python.pkg.dev/PROJECT_ID
# e.g. REGION=us-central1

# Configure Pip to use Artifact Registry

# TODO: why are these 'read' commands returning non-0?
set +e
read -r -d '' PYPIRC <<EOF
[distutils]
index-servers =     
    ${PIP_REPO}

[${PIP_REPO}]
repository: ${PIP_REPO_BASE_URL}/${PIP_REPO}/
EOF
set -e

echo "$PYPIRC" > $HOME/.pypirc

# TODO: why are these 'read' commands returning non-0?
set +e
read -r -d '' PYCONF <<EOF
[global]
index-url = ${PIP_REPO_BASE_URL}/${PIP_REPO}/simple/
EOF
set -e

mkdir -p ~/.pip
echo "$PYCONF" > $HOME/.pip/pip.conf

echo "PATH="\$\{PATH\}:/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin:${HOME}/.local/bin"" >> ~/.profile

echo "Pip environment configured! Please source ~/.profile to add Python executables to your current shell session:
      $ source ~/.profile"

