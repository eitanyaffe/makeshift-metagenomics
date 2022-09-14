# Setting up an account on the Google Cloud Platform

#### 1. Open an account on the Google Cloud Platform

Setup an account on https://console.cloud.google.com. You can open a free trial account on Google Cloud Platform (GCP). Trial accounts are limited by 8 cores, making them only suitable to run the demo pipeline. 

#### 2. Create makeshift service account, with a key

In the GCP console, go to IAM -> Service accounts and create service account. Make sure to set the Role to 'Owner'.

Go into the new account, locate the 'keys' area and press 'add key'. 

Select 'create new key' and select json.

A new json file will be saved locally on your computer. Keep this file safe, as it gives permissions to access all your cloud resources. Copy the file to a dedicated safe local directory (Here we use `$HOME/keys`). In the following command replace `<my_json_key>` with the name of the json key file that was downloaded from GCP.  

```
mkdir $HOME/keys
mv <my_json_key> $HOME/keys/makeshift.json
```

#### 3. Enable required GCP APIs 

Press the 'Enable APIs' button on this page: https://cloud.google.com/life-sciences/docs/process-genomic-data. Enable these 3 APIs:

* Cloud Life Sciences API
* Compute Engine API
* Google Cloud Storage JSON API

#### 4. Installing gcloud

Follow instructions on https://cloud.google.com/sdk/docs/install. Follow commands there until the command `gcloud init`.

#### 5. Configure gcloud to work with docker

```
gcloud auth configure-docker
```

#### 6. Install gsutil

gsutil is the most straightforward way to upload your data to GCP buckets. Follow installation instructions on https://cloud.google.com/storage/docs/gsutil.