# The Makeshift Metagenomic Environment

The Makeshift Metagenomic Environment (MME) is a command-line environment designed for the rapid development and deployment of data analysis pipelines. 

MME is developed by Eitan Yaffe (eitan.yaffe@gmail.com). It is distributed under the GPL-3.0 license.

Under the hood, MME workflows are implemented in the GNU Make language. MME uses docker to simplify the installation steps and achieve complete reproducibility. Parallelization is supported through the Google Cloud Platform (GCP). Jobs are submitted to GCP through dsub ([https://github.com/DataBiosphere/dsub](https://github.com/DataBiosphere/dsub)).

**Basic concepts**

* A *step* is one or more bash commands bundled together. For example, predicting genes on contigs using prodigal is a step. 
* A *module* combines steps into workflows. For example, the genes module handles gene-related topics including gene prediction and annotation.
* A *pipeline* describes how modules are combined and forms the entry point for users. For example, the assembly pipeline processes raw reads to produce metagenomic assemblies.
* Users define and customize how their data is processed in *configuration* files. This includes the names of I/O buckets and non-default variable settings. For example, a dataset that encompasses 2 subjects that were sequenced with 5 samples per subject can be described in a single configuration file that points to input files and tables.

A typical MME run involves applying pipeline steps to a specified user configuration. MME automatically launches nested jobs on GCP, as defined in the modules.

**List of current MME pipelines**

* The demo pipeline is a toy pipeline that demonstrated the basic functionality of MME. See the section 'Running the demo pipeline' below.
* The MME assembly pipeline is documented [here](docs/assembly_pipeline.md).

## Prerequisites

**GNU Make**. GNU Make is installed by default on most modern operating systems. You can run `which make` to verify that GNU Make is installed. If GNU Make is missing follow the installation instructions [here](https://www.gnu.org/software/software.html). 

**Docker**. Install Docker Desktop following the instruction supplied [here](https://docs.docker.com/engine/install/).

**Account on Google Cloud**. Create and configure an account on the Google Console. See instructions on how to enable various APIs that are required for proper MME use [here](docs/GCP.md). 

**Account on SendGrid (optional step)**. MME can send emails with job status updates, including job progress reports and errors. To enable this feature you will need to open an account with [SendGrid](https://signup.sendgrid.com/). Create an API key by following the instructions supplied [here](https://docs.sendgrid.com/ui/account-and-settings/api-keys).

## Installation

1) Position yourself the directory under which you want to place MME, and call the following commands. Here we install MME under the home directory `$HOME`. If you wish to install under a different directory replace `$HOME` with a directory of your choice. 

```
cd $HOME
git clone https://github.com/eitanyaffe/makeshift-metagenomics.git makeshift
cd makeshift && make init
```

2) Identify your GCP project name `<your_google_project>` through the GCP console or by calling this command:

```
gcloud projects list
```

3) You will need to edit your shell initialization script. In MacOS this file is called ~/.zshrc, while in most linux distributions this file is called ~/.bashrc. Here we refer to this file as .zshrc for brevity. Add these lines to .zshrc, while replacing `<your_google_project>` with the GCP project name.

```
export MAKESHIFT_ROOT=$HOME/makeshift
export MAKESHIFT_CONFIG=$HOME/makeshift/configs
export GCP_PROJECT_ID=<your_google_project>
export GCP_KEY=$HOME/keys/makeshift.json
```

4) If you wish to set-up email notifications via SendGrid add the following to your .zshrc, replacing `<your_email_address>` with your preferred email address and `<your_api_key>` with the SendGrid API key.

```
export MAKESHIFT_EMAIL=<your_email_address>
export SENDGRID_API_KEY=<your_api_key>
```

5) For quick access to the makeshift environment add these aliases to your .zshrc:

```
alias ms_image='f() { cd ${MAKESHIFT_ROOT}/pipes/metagenomics/p_assembly && make mdocker mdocker_push; date };f'
alias ms_pipe='f() { cd ${MAKESHIFT_ROOT}/pipes/metagenomics/p_$1 && make denv ${@:2}; date };f'
alias ms_pipe_dev='f() { cd ${MAKESHIFT_ROOT}/pipes/dev/p_$1 && make denv ${@:2}; date };f'
```

6) Open a new terminal and verify the definitions are in place by running:

```
echo ${MAKESHIFT_ROOT}
```
This should give the full path of the MME directory. 

## Running the demo pipeline

The demo pipeline serves as a unit test for MME. It launches jobs several small jobs on GCP and takes under 20 minutes to run.

1) **Open MME.** Start the demo pipeline environment with the examples/demo configuration file:

```
ms_pipe demo c=examples/demo
```

This command will start the pipeline environment in a new docker container. If the environment started successfully the bash prompt should start with `[[demo:demo-<your_google_project>]]`. In general, the syntax of the line prompt is `[[<pipeline_name>:<project_name>]]`. 

2) **Execute the pipeline.** Run the following command in MME:

```
make p_all
```

After launching the job, the `<run_key>` associated with the run will be printed for your reference. The `<run_key>` is a string identifier, of the form `top-l1-i10wdl686in4p`, which can be used to monitor or kill the entire run, including nested jobs.

## Monitoring jobs and tracking expenses

#### Monitoring jobs in MME

To see all active GCP instances open MME and run:

```
make dstat_s
```

#### Monitoring jobs in GCP

Job labels allow to monitor jobs in real-time in GCP (see [here](https://cloud.google.com/monitoring/docs/monitoring-overview)). Useful job labels include:

* ms-project-name: An identifier of an entire project `<project_name>`.
* ms-job-key-1: An identifier of a specific run `<run_key>`.

#### Monitoring expenses in GCP

GCP typically reports expenses after 24h in the Billing section, see [here](https://cloud.google.com/billing/docs/reports). The two labels above can be used to group or filter expense reports.


## Troubleshooting

If a run fails you can download the logs to a local directory and inspect what went wrong. In the command below replace `<job_key>` with your specific job key:

```
make m=gcp gcp_logs_download_key RUN_KEY=<job_key>
```

This will download the logs to a directory under `$(MAKESHIFT_ROOT)/logs`. 

If a run has fails on GCP it can be useful to attempt to reproduce the error locally. You can do that by adding the ```PAR_TYPE=local``` flag to your launching command. For example:

```
make p_all PAR_TYPE=local
```

To see the value of an MME variable run:
```
make p v=<some_variable>
```

For example, to see the value of the INPUT_BUCKET run:
```
make p v=INPUT_BUCKET
```

## Docker image

All external tools are described in a docker image, defined in modules/cloud/gcp/containers/mdocker-metagenomics/Dockerfile.

By default, MME uses the prepared docker image `eitanyaffe/mdocker-metagenomics` from Docker Hub. To work with your own image you need to remove the definition of `GCP_GCR_IMAGE_PATH` in the configuration file and run the following command on your shell from outside the MME:

```
ms_image
```

This will build the docker image and upload it to your Google Container Registry (GCR).

It can be useful to allow other users to directly access your docker images on GCR. To do that navigate in GCP to the IAM tab, click 'Add' and give the role of 'Artifact Registry Reader' to any GCP users that you wish to grant access to your GCR images.
