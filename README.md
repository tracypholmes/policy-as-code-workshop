# [Workshop] OWASP DevSlop: Exploring Policy as Code

How do you check for security requirements while you build your cloud infrastructure? In this workshop,
we'll walk through how to use policy as code to deliver and release an immutable machine image with
security in mind. Learn to use static analysis to check provisioning scripts for security requirements.

- Build a container image with Packer and Docker
- Write some unit tests which statically analyze both Packer and Docker configuration
- Write some integration tests which dynamically analyze a test container instance
- Add them to a delivery pipeline

Bring your own machine and make sure you install prerequisites!

> Note: If you find yourself struggling with the answer, check out
  the `solutions` branch. You can also [review the slides](https://speakerdeck.com/joatmon08/exploring-policy-as-code) for this workshop.

## Step 0: Prerequisites

### Requirements

Your machine must have a Linux subsystem to run some of the commands.
### Download and install

Download and install the following software:

- [Python](https://www.python.org/downloads/) 3.8+
- [Packer](https://www.packer.io/downloads) 1.7.2+
- [Docker for Desktop](https://www.docker.com/products/docker-desktop)
- [Ruby](https://www.ruby-lang.org/en/documentation/installation/) 3.0+

You will also need to set up a log infor the following:

- GitHub
- [Optional] Google Cloud Platform, review Step 4.

### Configure Chef Inspec

1. Install Chef Inspec.
   ```shell
   make inspec
   ```

1. You will need to accept the license agreement for Inspec. Make sure
   you review it first!
   ```shell
   inspec --chef-license=accept
   ```

1. Fork this repository.

1. Clone your fork.
   ```shell
   git clone git@github.com:<your github id>/policy-as-code-workshop.git
   ```

## Step 1: Use static analysis for configuration

We will use static analysis to test the configuration file to create our Docker
container in two methods: Packer and Docker.

You'll notice Packer and Docker have two different approaches. This gives you an
idea of what you might need to do to write custom rules for configurations versus
using open source tooling available.

### Method 1: Packer & Python

This workflow is something you can apply to virtual machines as well.
We show how to statically analyze a Packer configuration for compliance
and security testing.

`docker.pkr.hcl` is a Packer configuration that defines a Docker
container. How do we know that it will build a secure and compliant
Docker image?

We'll add a test to `test/unit` to check that the base image of the container
uses Ubuntu.

1. Install the required Python packages for testing the configuration. This includes
   `pytest`, a Python testing fraemwork, and `python-hcl2`, which we'll use to parse
   `docker.pkr.hcl`.
   ```shell
   pip3 install -r test/unit/requirements.txt
   ```

1. Run the unit tests.
   ```shell
   pytest test/unit
   ```

### Method 2: Docker & Hadolint

This workflow only applies to containers.
We show how to statically analyze a `Dockerfile` for compliance
and security best practices.

In this case, we do __not__ write our own rules. We'll use
[Hadolint](https://github.com/hadolint/hadolint) to check for
best practices in building our Dockerfile.

`Dockerfile` is a Docker configuration that defines a Docker
container. How do we know that it will build a secure and compliant
Docker image?

We can run `hadolint` to check problems with our Dockerfile.

```shell
docker run --rm -i hadolint/hadolint < Dockerfile
```

Notice that you did not have to build or run the application container!
Unit tests for static analysis do not require a runtime environment.

## Step 2: Use dynamic analysis for runtime configuration

Some things you can check by analyzing the files, while other
policy as code requires running infrastructure. Let's verify
the security and compliance of the __running__ container.

1. Build the application container image. It will be
   called `policy-as-code:latest`.
   ```shell
   make build
   ```

1. If you are running Docker for Desktop, you can use the
   `docker scan` command to scan the image dynamically! This
   will send information to Snyk.
   ```shell
   docker scan policy-as-code:latest
   ```

Notice we ran the `docker scan` command locally. If you run
this in pipelines or other automation, you will need to
register for [Snyk](https://snyk.io/) and get an API token.

There are open source options for scanning container images.
We'll be using Inspec's [Docker CIS Benchmarks](https://github.com/dev-sec/cis-docker-benchmark)
as an example. You'll also add your own Inspec tests
specific to the `policy-as-code` container.

We'll add a test to `test/integration` using Inspec which
verifies that the `fake-service` binary exists in the right
place and the user is not root. However, it requires
a running container.

1. Start the container.
   ```shell
   export CONTAINER_ID=$(docker run -d policy-as-code:latest)
   ```

1. Run the integration tests.
   ```shell
   inspec exec test/integration -t docker://${CONTAINER_ID}
   ```

1. You'll notice it fails! You need to correct the `Dockerfile`
   so that the integration tests pass. You'll need a few things,
   including:
   - Run the container as a user `ubuntu` and group `ubuntu`.
   - Set the default `ubuntu` user with a shell of `/bin/sh`.

1. You can also try running the
   [CIS Benchmark](https://github.com/dev-sec/cis-docker-benchmark)
   for Docker! We suggest starting with one test, mostly
   because there are a lot of them!
   ```shell
   inspec exec https://github.com/dev-sec/cis-docker-benchmark --controls 'docker-4.1'
   ```

1. Remove the container.
   ```shell
   docker rm -f ${CONTAINER_ID}
   ```
## Step 3: Add policy as code to delivery pipeline

1. Go to `.github/workflows/main.yml`. It has a few
   jobs added and they do not have too much to run.

1. First, add Hadolint scanning to run under the
   `static-analysis` job.

1. Next, add the Inspec integration test
   to the `dynamic-analysis` job.

## [Optional] Step 4: Release the container to Google Cloud Platform

Can you build the container image and
deploy it to Google Cloud Platform Cloud Run? This is an optional
step if you want to try to release the container to GCP.

For the accessibility of this workshop, we tried to avoid
any cost-incurring resources. You can attempt the __optional__
Terraform configuration, but it will incur a small cost
with GCP Cloud Run.

### Download and install

- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://www.terraform.io/downloads.html)

### Prerequisites

1. You must have a Google Cloud Platform (GCP) account.

1. You must have a Google Cloud Platform
   [project](https://developers.google.com/workspace/marketplace/create-gcp-project).

1. Make sure you've downloaded [gcloud CLI](https://cloud.google.com/sdk/docs/install).

1. Make sure to run `gcloud init` after installing. It will walk you
   through the needed steps.

1. Create a project using the console. Make note of your GCP project ID
   because it will be needed in later steps.

1. Set the project ID as an environment variable. Make sure you set it
   for each shell.
   ```shell
   export CLOUDSDK_CORE_PROJECT=<your project id>
   ```

1. Configure Docker with Google Container Registry credentials and enable
   the container registry on GCP.
   ```shell
   make gcr
   ```

### Run

1. Set the project ID as an environment variable. Make sure you set it
   for each shell.
   ```shell
   export CLOUDSDK_CORE_PROJECT=<your project id>
   ```

1. Build and push the container image to Google Container Registry.
   __This may incur a small cost!__
   ```shell
   make push
   ```

1. Go into the `test/e2e` directory.
   ```shell
   cd test/e2e
   ```

1. Initialize Terraform.
   ```shell
   terraform init
   ```

1. Deploy the example service to GCP Cloud Run and type
   "yes" at the prompt.
   ```shell
   terraform apply
   ```

### Clean up

Remove all resources with Terraform.

```shell
cd test/e2e && terraform destroy -auto-aprove
```

Delete all the images from Google Container Registry.

```shell
gcloud container images delete \
   gcr.io/${CLOUDSDK_CORE_PROJECT}/policy-as-code \
   --force-delete-tags  --quiet
```