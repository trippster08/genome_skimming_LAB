# Nanopore Long-Read Genome Skimming
1. [Local Computer Configuration](#local-computer-configuration) </br>
2. [Hydra Configuration](#hydra-configuration) </br>
  2.1. [Log into Hydra](#log-into-hydra) </br>
  2.2. [Project-specific directory](#project-specific-directory) </br>
  2.3. [Transfer files to hydra](#transfer-files-to-hydra) </br>
3. [Running the Pipeline](#running-the-pipeline) </br>
4. [QC Raw Reads](#qc-raw-reads) </br>
5. 

This protocol is to analyze [Oxford Nanopore](https://nanoporetech.com/) long read sequences for the purpose of recovering mitochondrial genomes from genomic DNA libraries. This pipeline is designed run multiple samples simultanteously on [Hydra](https://confluence.si.edu/display/HPC/High+Performance+Computing), Smithsonian's HPC, using [flye](https://github.com/mikolmogorov/Flye) for assembly, [Medaka](https://github.com/nanoporetech/medaka) for sequence correction, [GetOrganelle](https://github.com/Kinggerm/GetOrganelle) and [MitoFinder](https://github.com/RemiAllio/MitoFinder) for mitochondrial genome detection from assemblies, [MITOS](https://gitlab.com/Bernt/MITOS/) and [MitoFinder](https://github.com/RemiAllio/MitoFinder) for mitogenome annotation, and [Minimap2](https://github.com/lh3/minimap2) for mapping reads to mitogenomes. The pipeline assumes you have a current hydra account and are capable of accessing the SI network, either in person or through VPN. Our pipeline is specifically written for MacOS, but is compatible with Windows. See [Hydra on Windows PCs](https://confluence.si.edu/display/HPC/Logging+into+Hydra) for differences between MacOS and Windows in accessing Hydra.

I also have a pipeline for obtaining mitogenomes from Nanopore long reads, see [Long_Read.md](https://xxxxxxxxx). Hybrid (Nanopore/Illumina) analyses are coming. 

Much of this pipeline is run similarly to the short-read version, therefore much of the directions below are identical. You do not need to read the short-read directions found in the [README.md](xxxxxxx).

## Local Computer Configuration 
Make a project directory, and mulitple subdirectories on your local computer. Make this wherever you want to store your projects. Hydra is not made for long-term storage, so raw sequences, jobs, results, etc should all be kept here when your analyses are finished. Although it is not necessary, I use the same directory pattern locally as I use in Hydra. 

Make sure to replace "PROJECT" with your project name throughout.
```
mkdir -p PROJECT/data/raw PROJECT/jobs
```
Your raw reads should be in `data/raw/`. 
NOTE: As currently designed, this pipeline has a few naming requirements for raw reads. Reads should be `fastq.gz` or `fastq` formated, and needs to start with a unique sample name (that contains no underscores) and read number (either R1 or R2) later in the filename. Both sample name and read number must be separated from the remainder of the filename with underscores. Also, Hydra does not allow jobs names to start with a number, so if your sample names start with a number, change the name by adding at least one letter to the beginning of the filename (I usually use the initials of the researcher) before running this pipeline.

## Hydra Configuration 
All programs will be run through shared conda environments, so there is no need for the user to change any Hydra configurations or install any programs.

### Log into Hydra
Open the terminal app and log onto Hydra. You will need your hydra account password.
```
ssh USERNAME@hydra-login01.si.edu
```
 or
```
ssh USERNAME@hydra-login02.si.edu
```
### Project-specific Directory 
Go to the the directory assigned to you for short-term storage of large data-sets. Typically this will be `/scratch/genomics/USERNAME/`. Replace USERNAME with your hydra username.
```
cd /scratch/genomics/USERNAME
```
Make a project-specific directory, with the following subdirectories: `jobs/` and `data/raw/`. -p allows you to create subdirectories and any parental ones that don't already exist (in this case, PROJECT). I use the same directory tree here as on my local computer, to lessen confusion. Again, replace PROJECT with your project name.
```
mkdir -p PROJECT/data/raw PROJECT/jobs
```
### Transfer Files to Hydra 
Download the pipeline to jobs/ in your Hydra account using `wget`. This downloads a compressed file that contains all job files (\*.job), and shell scripts (\*.sh) necessary for your analysis. This command downloads a compressed file that will become a directory upon unzipping. Don't forget to move into your jobs folder first: `cd PROJECT/jobs`.
```
wget https://github.com/trippster08/genome_skimming_LAB/archive/refs/heads/main.zip
```
Unzip the pipeline, and move all the \*.sh, \*.job, and \*.R files from your newly unzipped directory into the job directory and the primer folder into the main project directory. Delete the now-empty pipeline directory and zipped download. This also places a directory filled with additional scripts (SPAdes and associated annotation scripts, flye, downloading SRA data, etc) into jobs/. If you want to run any of these scripts, move them from jobs/extra_scripts/ to jobs/.
```
unzip main.zip

mv genome_skimming_LAB-main/scripts_jobs/* genome_skimming_LAB-main/extra_scripts/* genome_skimming_LAB-main/long_read/* .
rm -r genome_skimming_LAB-main main.zip

```
Your raw reads should be copied into `data/raw/`. Download to your local computer and use scp or filezilla to upload to `data/raw/`. See [Transferring Files to/from Hydra](https://confluence.si.edu/pages/viewpage.action?pageId=163152227) for help with transferring files between Hydra and your computer.

## Running the Pipeline
This pipeline is designed to run each program on multiple samples simultaneously. For each program, the user runs a shell script that includes a path to the directory containing your input files. This shell script creates and submits a job file to Hydra for each sample in the targeted directory. After transeferring files to Hydra, the user should navigate to their jobs directory, which contains both job files and shell scripts, typcially `/scratch/genomics/USERNAME/PROJECT/jobs/`. All shell scripts should be run from this directory. Log files for each submitted job are saved in `jobs/logs/`. 

NOTE: Additional information for each program can be found in the `.job` file for each specific program. Included is program and parameter descriptions, including recommendations for alternative parameter settings. 

## QC Raw Reads
We will use two programs to evaluate the quality of our reads: [NanoPlot](https://github.com/wdecoster/NanoPlot) and [ToulligQC](https://github.com/GenomiqueENS/toulligQC). I use both because they give results slightly differently (and not completely overlapping), and since I haven't figured out which I prefer, I give the user the both options.  Both programs will output an html file that can be opened with any browser.

### Run NanoPlot and ToulligQC
Run both shell scripts, including the path to the directory containing your raw long read files. For most, it should be something like: 
`/scratch/genomics/USERNAME/PROJECT/data/raw/`. 
```
sh nanoplot.sh path_to_raw_sequences
```
```
sh toulligQC.sh path_to_raw_sequences
```
The results of these analyses are saved in `data/results/nanpore_analyses/` and `data/results/toulligqc_analyses