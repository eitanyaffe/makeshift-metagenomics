# The MME Assembly Pipeline

The MME assembly pipeline processes DNA short-read sequences of microbial communities, generating metagenomic asssemlies and identifying open reading frames (predicted genes).

## Quick-start: Processing an example dataset

The following test runs the first step of the assembly pipeline on a test dataset, defined in configs/examples/pp_test.

1) Open MME on the assembly pipeline and the examples/pp_test configuration:

```
ms_pipe assembly c=examples/pp_test
```

2) Launch the job on GCP:

```
make p_init_pipeline p_init_project top T=d_sgcc

```

3) Export the results to a local directory:

```
make p_export_assembly EXPORT_ASSEMBLY_VARIABLES="SGCC_COMPARE_TABLE SGCC_STATS_TABLE"
```

The test takes under an hour to complete.

## Input

The input of this pipeline is a set of pair-ended fastq files (compressed with gzip). The fastq files need to be uploaded to a GCP bucket. To create a new bucket follow instructions [here](https://cloud.google.com/storage/docs/creating-buckets). To copy data to the a new bucket consider using [gsutil](https://cloud.google.com/storage/docs/gsutil), a user-friendly CLI to work with GCP buckets. 

The relative paths of the fastq files, their sample identifiers, and their matching assembly names need to be specified in a tab-delimited table called the **library table**. The fictional table below represents an experiment in which Bob and Alice were sequenced with 5 samples each: 

assembly | lib | type   | canon | R1                    | R2    
-------- | --- | ------ | ----- | --------------------- | --------------------
Bob      | l1  | early  | A     | files/l1_R1.fastq.gz  | files/l1_R2.fastq.gz 
Bob      | l2  | early  | B     | files/l2_R1.fastq.gz  | files/l2_R2.fastq.gz 
Bob      | l3  | mid    | C     | files/l3_R1.fastq.gz  | files/l3_R2.fastq.gz 
Bob      | l4  | late   | D     | files/l4_R1.fastq.gz  | files/l4_R2.fastq.gz 
Bob      | l5  | late   | E     | files/l5_R1.fastq.gz  | files/l5_R2.fastq.gz 
Alice    | l6  | early  | A     | files/l6_R1.fastq.gz  | files/l6_R2.fastq.gz 
Alice    | l7  | early  | B     | files/l7_R1.fastq.gz  | files/l7_R2.fastq.gz 
Alice    | l8  | mid    | C     | files/l8_R1.fastq.gz  | files/l8_R2.fastq.gz 
Alice    | l9  | late   | D     | files/l9_R1.fastq.gz  | files/l9_R2.fastq.gz 
Alice    | l10 | late   | E     | files/l10_R1.fastq.gz | files/l10_R2.fastq.gz 

Notes:

* the 'assembly' column is an identifier of the microbial community or human host. The pipeline will co-assembly all samples that share an 'assemby' value.
* The 'lib' column is an identifier of the sequenced library.
* The 'type' column is an optional column that specifies how to group samples.
* The 'canon' column specifies a canonic cross-community sample identifer. This is required only if cross-community analysis is planned.
* The 'R1' and 'R2' columns specify the relative paths of the fastq files, within the input bucket. 

For an example of an input bucket, see the bucket `gs://poly-panner-example`.

## Setting up a new project

The simplest way to create a new project is to use an existing configuration file as a starting point, and customize it as needed. Here we show how create a new project called 'project-x' based on the examples/pp_test configuration.

1) Generate a new directory for the project under `${MAKESHIFT_CONFIG}`:

```
mkdir ${MAKESHIFT_CONFIG}/project-x
```

2) Copy the configuration file:

```
cp ${MAKESHIFT_CONFIG}/examples/pp_test/pp_test_cfg.mk ${MAKESHIFT_CONFIG}/project-x/project-x_cfg.mk
```

3) Open a text editor and edit the file `${MAKESHIFT_CONFIG}/project-x/project-x_cfg.mk`. The two variables which must be edited are:

* `PROJECT_NAME`: A string identifier of your project `<project_name>`.
* `INPUT_BUCKET`: The GCP bucket that contains your input files.
* `LIBS_INPUT_TABLE`: Path to your library table.

The configuration file is specified using the `c` parameter when openning MME. For example, to use the new configuration file we have created run:

```
ms_pipe assembly c=project-x
```

## Running the pipeline

Here we describe how to apply the pipline step-by-step.
 
1) Start the pipeline environment with a specified configuration file:

```
ms_pipe assembly c=<your_configuration_file>
```

2) Execute the following command (required only once per pipeline):

```
make p_init_pipeline
```

The command compiles c++ code and uploads code to dedicated code buckets on GCP.

3) Execute the following command (required only once per project):

```
make p_init_project
```

This command creates the output bucket.

4) Execute the pipeline:

```
make top
```

The 'top' command executes the entire pipeline. Other pipeline commands are defined in pipes/metagenomics/p_assembly/makefile.

The pipeline should complete processing the example dataset in under 4 hours.

## Output

To download the results run the following command, while replacing `<assembly_id>` with one of the assembly ids that were specified in the 'assembly' column in youe library table.

```
make p_export_assembly ASSEMBLY_ID=<assembly_id>
```

This will download all files to the directory `export/assembly/<project_name>/<assembly_id>/export_table.txt` under `$(MAKESHIFT_ROOT)`. An index file called `export_table.txt` is created in that directory. These files can be accessed from outside MME.

**Table of exported files**

| Variable                     | Module     | Description |
| ---------------------------- | ---------- | ----------- |
| `SGCC_COMPARE_TABLE`         | sgcc       | sourmash k-mer distance matrix |
| `STATS_READS_COUNTS`         | libs       | General library statistics |
| `STATS_DUPS`                 | libs       | Duplicate library statistics |
| `ASSEMBLY_CONTIG_FILE`       | assembly   | Contig table |
| `ASSEMBLY_CONTIG_TABLE`      | assembly   | Contig FASTA file |
| `GENE_FASTA_AA`              | genes      | Gene amino acid FASTA file|
| `GENE_FASTA_NT`              | genes      | Gene nucleotide FASTA file|
| `GENES_COVERAGE_GENE_MATRIX` | genes      | Gene RPK matrix |
