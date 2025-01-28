This project provides a working sample for integrating a Google Cloud compute instance with Artifact Registry on a network with no public egress connectivity.

Note: This project is not intended for production use. Please use this as reference material and automate accordingly.

Google Cloud users with high security requirements may be forced to provision compute workloads on networks with no public egress connectivity to the public Internet. Those compute workloads may be required to pull in packages (e.g. Python packages) from a package repository to build the software required to run the workload.

Artifact Registry provides good guidance on [configuring authentication to Artifact Registry for Python package repositories](https://cloud.google.com/artifact-registry/docs/python/authentication), but once crucial component is missing for workloads running on a no-public-egress network configuration. The "keyring", "keyrings.google_artifactregistry-auth", and all transitive dependencies are fetch from the public internet, by default from the PyPi index. When we're operating a compute instance on a network with no egress to the public Internet, we don't have the option to install the authentication helpers that we ultimately need to access our own private Artifact Repository repos. This presents a bit of a "chicken or the egg" problem that we need to circumvent.

This sample guide provides scripts to pre-populate the required Python authentication helper libraries, install the on the private host, and configure the "pip" utility to only fetch packages from your protected Artifact Registry repository.

The steps for running this outline are as follows:
1) "Public" VPC: Create a VPC with a subnet and attach a NAT Gateway
2) "Private" VPC: Create a VPC with a subnet (no NAT Gateway)
3) Create a "pip-auth-repo" Python Artifact Registry Repository for ONLY the Artifact Registry authentication helper libraries.
4) Create a "my-private-pip-packages" Python Artifact Registry Repository for all other private python repositories that you want to install.
4) Create "pip-auth-repo": a "Public" Compute Engine instance and attached it to the Public VPC network (alternatively provision the host with an "External IP Address")
5) Open a shell to the Public Compute Engine instance: 
  a) Download "keyring", "keyrings.google_artifactregistry-auth", and all transitive dependencies.
  b) Upload all packages to the "pip-auth-repo" registry.
6) Open a shell to the Private Compute Engine instance:
  a) Install the Artifact Registry authentication helpers from the "pip-auth-repo" (using 'gcloud')
  b) Configure the local pip environment to only use the Python Artifact Registry repository of your choice.
  c) "pip install" any packages from "my-private-pip-packages".
  
  Quickstart:

  1) Open a shell to the "Public" compute instance
  
  2) Configure env vars:

  ```BASH
  export REGION=us-central1
  export PIP_REPO_BASE_URL=https://${REGION}-python.pkg.dev/${PROJECT_ID}
  export PIP_REPO=my-pip-repo
  ```
  3) Install and Upload Artifact Registry Authentication Packages

  ```BASH
  ./public-host-upload-keyring.sh
  ```

  Note: You should see your pip repository populated with "keyring", "keyrings.google_artifactregistry-auth", and all transitive dependencies.

  4) Open a shell to the "Private" compute instance

  5) Configure env vars:

  ```BASH
  export REGION=us-central1
  export PIP_REPO_BASE_URL=https://${REGION}-python.pkg.dev/${PROJECT_ID}
  export PIP_REPO=my-pip-repo
  ```

  6) Install Artifact Registry Authentication Packages

  ```BASH
  ./private-host-install-keyring.sh
  ```

  7) Configure pip environment for use with private Artifact Registry repos 

  Note: If you use a different Artifact Registry repository for your own private packages, set the "PIP_REPO" and/or "PIP_REPO_BASE_URL" variable accordingly

  ```BASH
  ./configure-pip-env.sh

  source ~/.profile
  ```

  8) Done!
 
  Your host is now ready to install pip packages from your Artifact Repostitory Python repos.
