This project provides a working sample for integrating a Google Cloud Compute Engine instance running a network with no public egress connectivity with an Artifact Registry Python Repository.

Note: This project is not intended for production use. Please use this as reference material and automate accordingly.

Google Cloud users with high security requirements may be forced to provision compute workloads on networks with no public egress connectivity to the public Internet. Those compute workloads may be required to pull in packages (e.g. Python packages) from a package repository to build the software required to run the workload.

Artifact Registry provides good guidance on [configuring authentication to Artifact Registry for Python package repositories](https://cloud.google.com/artifact-registry/docs/python/authentication), but unfortunately this approach does not work directly on a no-public-egress network configuration. The "keyring", "keyrings.google_artifactregistry-auth", and transitive dependencies are hosted on the public internet via the default from the PyPi index. Given that our host will have no connectity to the PyPi index, we're presented with a bit of a "chicken or the egg" problem that we need to circumvent.

This sample guide provides 2 potential solutions for this challenge:
1) Using a Python Artifact Registry Remote Repository pointing to PyPi accessed via "Private Host" (<-- most straightforward)

![pip_private_ar_remote_repo](https://github.com/user-attachments/assets/70b85523-d523-450e-9af9-2a4e01a0b887)

3) Using a Python Artifact Registry Standard Repository pre-populated by a "Public Host", and then accessed by a "Private Host"

![pip_private_ar_standard_repos](https://github.com/user-attachments/assets/a928815c-9a89-4d95-b862-1dd4cc2a4b0f)



### 1) TODO

### 2) Artifact Registry Standard Repository
This sample solution provides scripts to pre-populate the required Python authentication helper libraries in an Artifact Registry repo, install the authentication helper libaries on the private host, and configure the "pip" utility to only fetch packages from your private Artifact Registry repository.

The scripts are designed to be run on an environment with the following general configuration:
1) "Public" VPC: Create a VPC with a subnet and attach a NAT Gateway
2) "Private" VPC: Create a VPC with a subnet (no NAT Gateway)
3) "pip-auth-repo" Python Artifact Registry Repository for ONLY the Artifact Registry authentication helper libraries.
4) "my-private-pip-packages" Python Artifact Registry Repository for all other private python repositories that you want to install.
4) "pip-auth-repo": a "Public" Compute Engine instance and attached it to the Public VPC network (alternatively provision the host with an "External IP Address")

The following is an outline of behavior of the included scripts:

1) Open a shell to the Public Compute Engine instance:
  * Download "keyring", "keyrings.google_artifactregistry-auth", and all transitive dependencies.
  * Upload all packages to the "pip-auth-repo" registry.
2) Open a shell to the Private Compute Engine instance:
  * Install the Artifact Registry authentication helpers from the "pip-auth-repo" (using 'gcloud')
  * Configure the local pip environment to only use the Python Artifact Registry repository of your choice.
  * "pip install" any packages from "my-private-pip-packages".
  
  Usage:

  1) Open a shell to the "Public" compute instance and copy over this repo
  
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

  4) Open a shell to the "Private" compute instance and copy over this repo

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

  Note: If you use a different Artifact Registry repository for your own private packages (recommended), set the "PIP_REPO" and/or "PIP_REPO_BASE_URL" variable accordingly

  ```BASH
  ./configure-pip-env.sh

  source ~/.profile
  ```

  8) Done!
 
  Your host is now ready to install pip packages from your Artifact Repostitory Python repos.
