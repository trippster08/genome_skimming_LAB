# Genome Skimming Pipeline for LAB
1. [Local Computer Configuration](#Local-Computer-Configuration) </br>
2. [Hydra Configuration](#Hydra-Configuration) </br>
  2.1. [Log into Hydra](#Log_into_Hydra) </br>
  2.2. [Project-specific directory](#Project-specific-directory) </br>
  2.3. [Transfer files to hydra](#Transfer-files-to-hydra) </br>
3. [Running the Pipeline](#Running-the-Pipeline) </br>
4. [FastQC Raw Reads](#FastQC-Raw-Reads) </br>
  4.1. [Run FastQC](#Run-Fastqc) </br>
  4.2. [Download Results](#Download-Results) </br>    
5. [Trimming and Filtering Raw Reads](#Trimming_and_Filtering_Raw_Reads) </br>
6. [FastQC Trimmed Reads](#FastQC-Trimmed-Reads) </br>
  6.1. [Run FastQC](#Run-Fastqc) </br>
  6.2. [Download Results](#Download-Results) </br>
7. [SPAdes](#SPAdes) </br>
  7.1. [Run SPAdes](#Run-SPAdes) </br>
  7.2. [Move and Rename SPAdes Scaffolds](#Move-and-Rename-SPAdes-Scaffolds) </br>
8. [MitoFinder](#MitoFinder) </br>
  8.1. [Run MitoFinder using Trimmed Reads](#Run-MitoFinder-using-Trimmed-Reads) </br>
  8.2. [Run MitoFinder using SPAdes Scaffolds](#Run-MitoFinder-using-SPAdes-Scaffolds) </br>
  8.3. [Move MitoFinder Final Results Directory](#Move-MitoFinder-Final-Results-Directory) </br>
  8.4. [Download MitoFinder Final Results](#Download-MitoFinder-Final-Results)  </br>
9. [Download Results](#Download-Results) </br>

This protocol is to analyze paired-end or single-read demultiplexed illumina sequences for the purpose of recovering mitochondrial genomes from genomic DNA libraries. This pipeline is designed to use Hydra, Smithsonian's HPC, to run `FastQC`, `fastp`, `MitoFinder`, and `SPAdes`. The pipeline assumes you have a current hydra account and are capable of accessing the SI network, either in person or through VPN. Our pipeline is specifically written for MacOS, but is compatible with Windows. See https://confluence.si.edu/display/HPC/Logging+into+Hydra to see differences between MacOS and Windows in accessing Hydra.

## Local Computer Configuration 
Make a project directory, and mulitple subdirectories on your local computer. Make this wherever you want to store your projects. Hydra is not made for long-term storage, so raw sequences, jobs, results, etc should all be kept here when your analyses are finished. Although it is not necessary, I use the same directory pattern locally as I use in Hydra. 

Make sure to replace "PROJECT" with your project name throughout.
```
mkdir -p <PROJECT>/data/raw <PROJECT>/jobs
```
Your raw reads should be in `<PROJECT>/data/raw` (or any directory meant to hold only raw read files).

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
Go to the the directory assigned to you for short-term storage of large data-sets. Typically this will be `/scratch/genomics/<USERNAME>`. Replace USERNAME with your hydra username.
```
cd /scratch/genomics/<USERNAME>
```
Make a project-specific directory, with the following subdirectories: `jobs` and `data/raw`. -p allows you to create subdirectories and any parental ones that don't already exist (in this case, PROJECT). I use the same directory tree here as on my local computer, to lessen confusion. Again, replace PROJECT with your project name.
This pipeline is not dependent upon the directory tree shown, so you can set up your space differently, if you prefer. The only two directories that are required are `/data` and `/jobs` but you can name them whatever you like, and neither necessarily have to be in any particular place.This pipeline does create seveal new directories: `/data/trimmed_sequences`, `/data/results`, and within `/data/results` program-specific directories for those results, and `/jobs/logs`. If you don't want these directories created, or want them in different places, they can be changed in the shell scripts. 
```
mkdir -p <PROJECT>/data/raw <PROJECT>/jobs
```
### Transfer Files to Hydra 
You will need to transfer all the necessary files for this pipeline to your Hydra account. This includes raw read files (`*.fastq.gz`), job files (`*.job`), and shell scripts (`*.sh`).
Your raw reads should be copied into `<PROJECT>/data/raw`. Both job files and shell scripts should be copied into `<PROJECT>/jobs`. I usually use scp or filezilla for file transfers. See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help with transferring files between Hydra and your computer. 

NOTE: Hydra does not allow jobs names to start with a number, so if your sample names start with a number, you must change the name before running this pipeline.

## Running the Pipeline
This pipeline is designed to run each program on multiple samples simultaneously. For each program, the user runs a shell script that includes a path to the directory containing your input files. This shell script creates and submits a job file to Hydra for each sample in the targeted directory. After transeferring files to Hydra, the user should navigate to their jobs directory, which contains both job files and shell scripts, typcially `/scratch/genomics/<USERNAME>/<PROJECT>/jobs`. All shell scripts should be run from this directory. Log files for each submitted job are saved in `<PROJECT>/jobs/logs`. As mentioned earlier, while I find 
NOTE: Additional information for each program can be found in the `.job` file for each specific program. Included is program and parameter descriptions, including recommendations for alternative parameter settings. 

## `FastQC` Raw Reads
We first run `FastQC` on all our reads to check their quality and help determine our trimming parameters. 

### Run FastQC

Run the `FastQC` shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/raw`. 
```
sh fastqc_genomeskimming.sh <path_to_raw_sequences>
```
If you do not enter the path to the raw sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding  that path should fix these errors.

### Download Results

Download the directory containing the `FastQC` results (it should be `/data/raw/fastqc_analyses`) to your computer. Open the html files using your browser to examine your read quality. Interpreting `FastQC` results can be tricky, and will not be discussed here. See LAB staff or others familiar with `FastQC` for help.

## Trimming and Filtering Raw Reads

After the initial QC, we trim all reads to remove poor quality basepairs and residual adapter sequence using `fastp`, a program that trims similarly to `Trimmomatic` (the trimming program we previously used) but is significantly faster. I have found that `fastp` does filter and trim more aggressviely using the similar parameters (i.e. you end up with slightly fewer and shorter trimmed sequences), so the quality filtering parameters may need to be evaluated further. One advantage is that both R1 and R2 unpaired trimmed reads (reads for which the sequence in one direction did not pass quality filtering) can be saved into the same file, so there is no need for concatenation before using trimmed reads in `SPAdes`.

`fastp` does not require an illumina adapter to remove adapter sequences, but you can supply one for better adapter trimming, and we use one here. LAB uses two types of adapters, itru and nextera. Because most of the genome-skimming library prep so far use the itru adapters, I have included a fasta file for these, called `itru_adapters.fas`. We can provide a nextera adapter file upon request. This pipeline currently points to a directory containing the itru adapter file, if you want to use your own adapter file, you will need to change the path following the command `--adapter_fasta` in `fastp.job`.

Based on the quality of your reads (as determined by `FastQC`), you may want to edit the parameters in  `fastp.job`. The job file contains descriptions and suggestions for each parameter. 

Run the `fastp` shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/raw`. 

```
sh fastp.sh <path_to_raw_sequences>
```
If you do not enter the path to the raw sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.
Trimmed reads will be saved in `/data/trimmed_sequences`.

## FASTQC TRIMMED READS 
We next run `FastQC` on all our trimmed reads to check our trimming parameters. We will run the same shell file and job file we ran the first time, just using a different target directory.

### Run FastQC
Go to the directory containing your job files. The shell file below, and the job file that it modifies and submits to Hydra, `fastqc.job` should both be here.  Your trimmed reads should already be in `/data/trimmed_sequences`. 

Run the `FastQC` shell script, including the path to the directory containing your trimmed files. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
```
sh fastqc_genomeskimming.sh <path_to_raw_sequences>
```
If you do not enter the path to the trimmed sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.

### Download Results
Download the directory containing the `FastQC` results (it should be `/data/trimmed_sequences/fastqc_analyses`) to your computer. Open the html files using your browser to examine how well you trimming parameters worked. Interpreting `FastQC` results can be tricky, and will not be discussed here. See LAB staff or others familiar with `FastQC` for help. You may need to retrim using different parameters, depending upon the quality of the trimmed reads.

## SPAdes 

We are going to run `SPAdes` on all our trimmed paired and unpaired reads. `SPAdes` performs a de-novo assembly using both pair-end and single-end reads and outputs a set of contigs or scaffolds. The `SPAdes` documentation suggests using scaffolds instead of contigs in downstream applications. 

### Run SPAdes 

Run the `SPAdes` shell script, including the path to the directory containing your trimmed read files. For most, it should be something like: `/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
```
sh spades_multi_hydra.sh <path_to_trimmed_sequences>
```
If you do not enter the path to the trimmed sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.

Your results should be in `/data/results/spades`. The results for each sample will be in a separate folder, named with the sample name. 

### Move and Rename SPAdes Scaffolds

`SPAdes` recommends using the `scaffolds.fasta` file as resulting sequences, and saves these scaffolds in `/data/results/spades/<SAMPLE>` as a generic `scaffolds.fasta` file. This makes it difficult to batch transfer these files, because there is no sample differentiation. To fix this, run this shell script which copies all `scaffolds.fasta ` files into a new directory `/data/results/spades_scaffolds` and renames them with their sample name. This script also copies the `.log` file for each sample into `/data/results/spades_scaffolds`.

Run `rename_spades_scaffolds.sh`, including the path to the `SPAdes` results directory, usually: `/scratch/genomics/<USERNAME>/<PROJECT>/data/results/spades`.
```
sh rename_spades_scaffolds.sh <path_to_spades_results>
```
If you do not enter the path to the spades results directory in the command, or enter a path to a directory that does not contain sample-specific directories containing `scaffolds.fasta` files, you will get the following error "Correct path to SPAdes results not entered". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.

## MitoFinder

We are going to run `MitoFinder` on two different sets of data to try to find full mitochondrial genomes. 
* We will run `MitoFinder` using our paired-end trimmed reads as our input. `MitoFinder` will assemble reads using the program `MEGAHIT` and then annotate assemblies based on your reference file. You may run this simultaneously with your `SPAdes` run.
* We will run `MitoFinder` using the scaffolds that result from the `SPAdes` assembly. These assemblies may be more likely to contain the entire mitochondrial genome, because unlike `MitoFinder`, `SPAdes` uses trimmed single-end reads in addition to paired-end reads, and therefore utilizes more reads in its assembly. `MitoFinder` also runs more efficiently with scaffolds as inputs because it does not need to perform an assembly step. However, you must first wait for your `SPAdes` run to finish before starting this one.

You do not have to run `MitoFinder` twice. If you only want to run one version, I would recommend running `MitoFinder` using the `SPAdes` scaffolds as input. `SPAdes` typcially results in a longer mitogenome scaffolds, but there are occasions where `MitoFinder` with its `MEGAHIT` assembler results in a longer contig. I have yet to see a situation where one finds the entire mitogenome, while the other does not, but I am sure there are instances in which it happens. If time is short, you will most likely be fine using  `MitoFinder` using trimmed reads, but if this fails to yeild the entire mitogenome, you will need to run both `SPAdes` and `MitoFoinder`. This will greatly enlongate your run time, without guaranteeing you will find the mitogenome.   

### Run MitoFinder using Trimmed Reads

MitoFinder requires a mitochondrial genome database in GenBank (.gb) format. This pipeline currently uses a metazoan mitochondrial reference database downloaded from GenBank. If you would like to use a different reference database, follow the directions here: https://github.com/RemiAllio/MitoFinder/blob/master/README.md#how-to-get-reference-mitochondrial-genomes-from-ncbi to make your own, and save it in your home directory. You will have to alter `mitofinder.job` to point to the location of your database.

Run the `MitoFinder` shell script, including the path to the directory containng your trimmed read files and the number representing the genetic code you wish to use. For most, the path should be something like: `/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebratge mitochondrial DNA). For other taxa, see the `.job ` file for a complete list. Results of these analyses are saved in `/data/results/mitofinder`
```
sh mitofinder.sh <path_to_trimmed_sequences> <genetic_code>
```
 If you do not enter the path to the trimmed sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors. If you don't include a number representing a genetic code, you will get the following error "Genetic code not entered (should be a number between 1 and 25)".

### Run MitoFinder using SPAdes Scaffolds

MitoFinder requires a mitochondrial genome database in GenBank (.gb) format. This pipeline currently uses a metazoan mitochondrial reference database downloaded from GenBank. If you would like to use a different database follow the directions here: https://github.com/RemiAllio/MitoFinder/blob/master/README.md#how-to-get-reference-mitochondrial-genomes-from-ncbi to make your own, and save it in your home directory. You will have to alter `mitofinder_annotate_spades.job` to point to the location of your database.

Run the  `MitoFinder` for annotating spades scaffolds shell script, including the path to the directory containg your `SPAdes` scaffolds files and the number representing the genetic code you wish to use. For most, the it should be something like: `/scratch/genomics/<USERNAME>/<PROJECT>/data/results/spades/scaffolds`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebrate mitochondrial DNA). For other taxa, see the `.job ` file for a complete list. Results of these analyses are saved in `/data/results/mitofinder_spades`
```
sh mitofinder_annotate_spades.sh <path_to_spades_scaffolds>
```
If you do not enter the path to the `SPAdes` scaffolds in the command, or enter a path to a directory that does not contain `scaffolds.fasta` files, you will get the following error "Correct path to SPAdes scaffolds files not entered (*scaffolds.fasta)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors. If you don't include a number representing a genetic code, you will get the following error "Genetic code not entered (should be a number between 1 and 25)".

### Move MitoFinder Final Results Directory
The most important information from a `MitoFinder` analysis is saved in the `<SAMPLE>_Final_Results` directory. Because this directory is found in each sample-specific results directory, downloading these diretories from many sample runs can be time-consuminug. To make downloading easier, here is a shell script that copies `<SAMPLE>_Final_Results` from all samples into a single `/data/results/mitofinder_final_results` directory. This script also copies the `.log` file for each sample into `/data/results/mitofinder_final_results`.

Run `copy_mitofinder_final_results.sh`, including the path to the `MitoFinder` results directory, either: `/data/results/mitofinder` or `/data/results/mitofinder_spades`.
```
sh copy_mitofinder_final_results.sh <path_to_mitofinder_results>
```

### Download Results
Finally, we download all the directories containing our results. There should be one for all `mitofinder` results (`/data/results/mitofinder_final_results`) and one for `SPAdes` scaffolds (`/data/results/spades_scaffolds`). You may want to download additional files depending upon what you or your group decides to keep, but these are the immediately most important results.
