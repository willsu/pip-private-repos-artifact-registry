### Description

This project provides a working sample for integrating a Google Cloud Compute Engine instance running a network with no public egress connectivity with an Artifact Registry Python Repository.

Note: This project is not intended for production use. Please use this as reference material and automate accordingly.

Google Cloud users with high security requirements may be forced to provision compute workloads on networks with no public egress connectivity to the public Internet. Those compute workloads may be required to pull in packages (e.g. Python packages) from a package repository to build the software required to run the workload.

Artifact Registry provides good guidance on [configuring authentication to Artifact Registry for Python package repositories](https://cloud.google.com/artifact-registry/docs/python/authentication), but unfortunately this approach does not work directly on a no-public-egress network configuration. The "keyring", "keyrings.google_artifactregistry-auth", and transitive dependencies are hosted on the public internet via the default from the PyPi index. Given that our host will have no connectity to the PyPi index, we're presented with a bit of a "chicken or the egg" problem that we need to circumvent.

### Solutions

This sample guide provides 2 potential solutions for this challenge:

Option 1: Using a Python Artifact Registry Remote Repository pointing to PyPi accessed via "Private Host" (<-- most straightforward)

![pip_private_ar_remote_repo](https://github.com/user-attachments/assets/70b85523-d523-450e-9af9-2a4e01a0b887)

Option 2: Using a Python Artifact Registry Standard Repository pre-populated by a "Public Host", and then accessed by a "Private Host"

![pip_private_ar_standard_repos](https://github.com/user-attachments/assets/a928815c-9a89-4d95-b862-1dd4cc2a4b0f)


Note: The configuration scripts will configure the hosts to use the Python binaries located in the "/usr/lib/google-cloud-sdk/platform/bundledpythonunix/bin", which is typical of stock GCE VM images running on Google Cloud. Please modify the scripts to use a different Python installation, if needed.

### 1) Artifact Registry Remote Repository
This sample solution provides scripts to pre-populate the required Python authentication helper libraries in a Standard Artifact Registry repo, install the authentication helper libaries on the private host, and configure the "pip" utility to only fetch packages from your private Artifact Registry repository.

The scripts are designed to be run on an environment with the following general configuration:
1) "Private" VPC: a VPC with a subnet (no NAT Gateway, Private Google Access enabled)
2) "remote-pip-repo" a Remote Artifact Registry Repository for Python configured to use the PyPi Index.
3) "private-host": a "Private" Compute Engine instance and attached to the Private VPC network\
4) "Compute Service Acount": grant the "Artifact Registry Reader" Role to the default Computer Service account (or whatever Service Account is attached to the "private-host")

Instructions:

0) Ensure you have provisioned the Google Cloud resources as described above.

1) Open a shell via SSH to the "Private" compute instance and copy over this repo

2) Configure env vars:

  ```BASH
  # Set REGION and PROJECT_ID, or replace the PIP_HOST var accordingly.
  # Omit the scheme in the PIP_HOST ('https://' will be used by default) var.

  export PIP_HOST=${REGION}-python.pkg.dev/${PROJECT_ID}
  export PIP_REPO=my-pip-repo
  ```

3) Run the private host installer script

  ```BASH
  ./private-host-install-keyring.sh
  ```

4) Configure pip environment for use with your private Artifact Registry repos 

  Note: If you use a different Artifact Registry repository for your own private packages (recommended), set the "PIP_REPO" and/or "PIP_HOST" variable accordingly

  ```BASH
  ./configure-pip-env.sh

  source ~/.profile
  ```
 
Your host is now ready to install pip packages from your Artifact Repostitory Python repos!

```BASH
# You are now able to install packages via pip from your configured Artiface Registry repositories.
pip install my-private-package
```

### 2) Artifact Registry Standard Repository
This sample solution provides scripts to pre-populate the required Python authentication helper libraries in a Standard Artifact Registry repo, install the authentication helper libaries on the private host, and configure the "pip" utility to only fetch packages from your private Artifact Registry repository.

The scripts are designed to be run on an environment with the following general configuration:
1) "Public" VPC: Create a VPC with a subnet and attach a NAT Gateway
2) "Private" VPC: Create a VPC with a subnet (no NAT Gateway, Private Google Access enabled)
3) "pip-auth-repo" Python Artifact Registry Repository for the Artifact Registry authentication helper libraries.
4) "my-private-pip-packages" Python Artifact Registry Repository for all other private python repositories that you want to install.
5) "public-host": a "Public" Compute Engine instance and attached to the Public VPC network (alternatively provision the host with an "External IP Address")
4) "private-host": a "Private" Compute Engine instance and attached to the Private VPC network
  
Installation:
0) Ensure you have provisioned the Google Cloud resources as described above.

1) Open a shell via SSH to the "Public" compute instance and copy over this repo

2) Configure env vars (set host to the a Standard Python Artifact Registry that will store the keyring authentication packages):

  ```BASH
  # Set REGION and PROJECT_ID, or replace the PIP_HOST var accordingly.
  # Omit the scheme in the PIP_HOST ('https://' will be used by default) var.

  export PIP_HOST=${REGION}-python.pkg.dev/${PROJECT_ID}
  export PIP_REPO=my-pip-repo
  ```

3) Run the private host installer script

  ```BASH
  ./public-host-install-keyring.sh
  ```

Note: You should see your PIP_REPO repository populated with "keyring", "keyrings.google_artifactregistry-auth", and all transitive dependencies. At this time, you may delete your "public-host" VM.

4) Open a shell via SSH to the "Private" compute instance and copy over this repo

5) Configure env vars and (set the host to the same Artifact Registry repo where the keyring authentication were uploaded):

  ```BASH
  # Set REGION and PROJECT_ID, or replace the PIP_HOST var accordingly.
  # Omit the scheme in the PIP_HOST var ('https://' will be used by default).

  export PIP_HOST=${REGION}-python.pkg.dev/${PROJECT_ID}
  export PIP_REPO=my-pip-repo
  ```

6) Run the private host installer script

  ```BASH
  ./private-host-install-keyring.sh
  ```

7) Configure pip environment for use with private Artifact Registry repos 

  Note: If you use a different Artifact Registry repository for your own private packages (recommended), set the "PIP_REPO" and/or "PIP_HOST" variable accordingly

  ```BASH
  ./configure-pip-env.sh

  source ~/.profile
  ```

Your host is now ready to install pip packages from your Artifact Repostitory Python repos!

```BASH
# You are now able to install packages via pip from your configured Artiface Registry repositories.
pip install my-private-package
```


  ```

  8) Done!
 
  Your host is now ready to install pip packages from your Artifact Repostitory Python repos.
