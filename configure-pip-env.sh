#!/bin/bash
set -uo pipefail

# e.g. PIP_REPO=my-pip-repo
# e.g. PIP_HOST=us-central1-python.pkg.dev/my-project-id

# Configure Pip to use Artifact Registry

read -r -d '' PYPIRC <<EOF
[distutils]
index-servers =     
    ${PIP_REPO}

[${PIP_REPO}]
repository: https://${PIP_HOST}/${PIP_REPO}/
EOF

echo "$PYPIRC" > $HOME/.pypirc

read -r -d '' PYCONF <<EOF
[global]
index-url = https://${PIP_HOST}/${PIP_REPO}/simple/
EOF

mkdir -p ~/.pip
echo "$PYCONF" > $HOME/.pip/pip.conf

echo "PATH="\$\{PATH\}:/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin:${HOME}/.local/bin"" >> ~/.profile

echo "Pip environment configured! Please source ~/.profile to add Python executables to your current shell session:
$ source ~/.profile"

