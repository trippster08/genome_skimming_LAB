# Genome Skimming Pipeline for LAB
1. [Local Computer Configuration](#Local-Computer-Configuration) </br>
2. [Hydra Configuration](#Hydra-Configuration) </br>
  2.1. [Log into Hydra](#Log_into_Hydra) </br>
  2.2. [Project-specific directory](#Project-specific-directory) </br>
  2.3. [Transfer files to hydra](#Transfer-files-to-hydra) </br>
3. [Running the Pipeline](#Running-the-Pipeline) </br>
4. [FastQC Raw Reads](#FastQC-Raw-Reads) </br>
  4.1. [Run FastQC](#Run-Fastqc) </br>
  4.2. [Download Raw-Reads FastQC Results](#Download-Raw-Reads-FastQC-Results) </br>    
5. [Trimming and Filtering Raw Reads](#Trimming-and-Filtering-Raw-Reads) </br>
6. [FastQC Trimmed Reads](#FastQC-Trimmed-Reads) </br>
  6.1. [Run FastQC](#Run-Fastqc) </br>
  6.2. [Download FastQC of Trimmed Reads](#Download-FastQC-of-Trimmed-Reads) </br>
7. [SPAdes](#SPAdes) </br>
  7.1. [Run SPAdes](#Run-SPAdes) </br>
  7.2. [Move and Rename SPAdes Contigs](#Move-and-Rename-SPAdes-Contigs) </br>
  7.3. [Download Error-Corrected Reads](Download-Error-Corrected-Reads) </br>
8. [MitoFinder](#MitoFinder) </br>
  8.1. [Run MitoFinder using SPAdes Contigs](#Run-MitoFinder-using-Adapter-Trimmed-Reads) </br>
  8.3. [Move MitoFinder Final Results Directory](#Move-MitoFinder-Final-Results-Directory) </br>
  8.4. [Download MitoFinder Final Results](#Download-MitoFinder-Final-Results)  </br>
9. [Download Results](#Download-Results) </br>

This protocol is to analyze paired-end or single-read demultiplexed illumina sequences for the purpose of recovering mitochondrial genomes from genomic DNA libraries. This pipeline is designed to use Hydra, Smithsonian's HPC, to run fastQC, fastp, SPAdes, and MitoFinder. The pipeline assumes you have a current hydra account and are capable of accessing the SI network, either in person or through VPN. Our pipeline is specifically written for MacOS, but is compatible with Windows. See https://confluence.si.edu/display/HPC/Logging+into+Hydra to see differences between MacOS and Windows in accessing Hydra.

This protocol currently includes methods to quality and adapter trim and filter raw reads, error-correct and assemble trimmed reads, and annotate assemblies. It does not yet include what to do with your assembled mitogenome, including checking for compelete annotation, quality of assembly and annotation, submission to GenBank, etc. I hope to add many of these steps soon. You can download this entire repository, including all `.job` and `.sh` files using this link: [Genome Skimming @ LAB](https://github.com/trippster08/genome_skimming_LAB/archive/refs/heads/main.zip).

## Local Computer Configuration 
Make a project directory, and mulitple subdirectories on your local computer. Make this wherever you want to store your projects. Hydra is not made for long-term storage, so raw sequences, jobs, results, etc should all be kept here when your analyses are finished. Although it is not necessary, I use the same directory pattern locally as I use in Hydra. 

Make sure to replace "PROJECT" with your project name throughout.
```
mkdir -p <PROJECT>/data/raw <PROJECT>/jobs
```
Your raw reads should be in `<PROJECT>/data/raw` (or any directory meant to hold only raw read files). 
NOTE: As currently designed, this pipeline requires raw data to be `fastq.gz` formated, and to be named in the default Illumina manner, with 5 elements (sample name, barcode number, lane number, read number, and "001") all separated by underscores (i.e. Sample1_S001_L001_R1_001.fastq.gz). Also, Hydra does not allow jobs names to start with a number, so if your sample names start with a number, change the name to add a letter (I usually use the initials of the researcher) before running this pipeline.

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

## Running the Pipeline
This pipeline is designed to run each program on multiple samples simultaneously. For each program, the user runs a shell script that includes a path to the directory containing your input files. This shell script creates and submits a job file to Hydra for each sample in the targeted directory. After transeferring files to Hydra, the user should navigate to their jobs directory, which contains both job files and shell scripts, typcially `/scratch/genomics/<USERNAME>/<PROJECT>/jobs`. All shell scripts should be run from this directory. Log files for each submitted job are saved in `<PROJECT>/jobs/logs`. As mentioned earlier, while I find 
NOTE: Additional information for each program can be found in the `.job` file for each specific program. Included is program and parameter descriptions, including recommendations for alternative parameter settings. 

## fastQC Raw Reads
We first run fastQC on all our reads to check their quality and help determine our trimming parameters. 

### Run FastQC
Run the fastQC shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/raw`. 
```
sh fastqc_genomeskimming.sh <path_to_raw_sequences>
```
If you do not enter the path to the raw sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding  that path should fix these errors.

### Download Raw-Reads FastQC Results
Download the directory containing the fastQC results (it should be `/data/raw/fastqc_analyses`) to your computer. Open the html files using your browser to examine your read quality. Interpreting fastQC results can be tricky, and will not be discussed here. See LAB staff or others familiar with fastQC for help.

## Trimming and Filtering Raw Reads
We are going to trim all our reads to remove poor quality basepairs and residual adapter sequence using fastp, a program that trims similarly to `Trimmomatic` (the trimming program we previously used), but is significantly faster. fastp also filters out poor-quality or exceptionally short reads. I have found that fastp does filter and trim more aggressviely using the similar parameters (i.e. you end up with slightly fewer and shorter trimmed sequences), so the quality filtering parameters may need to be evaluated further. One advantage is that both R1 and R2 unpaired trimmed reads (reads for which the sequence in one direction did not pass quality filtering) can be saved into the same file, so there is no need for concatenation before using trimmed reads in `SPAdes`.

fastp does not require an illumina adapter to remove adapter sequences, but you can supply one for better adapter trimming, and we use one here. LAB uses two types of adapters, itru and nextera. Because most of the genome-skimming library prep so far use the itru adapters, I have included a fasta file for these, called `itru_adapters.fas`. We can provide a nextera adapter file upon request. This pipeline currently points to a directory containing the itru adapter file, if you want to use your own adapter file, you will need to change the path following the command `--adapter_fasta` in `fastp.job`.

Based on the quality of your reads (as determined by fastQC), you may want to edit the parameters in  `fastp.job`. The job file contains descriptions and suggestions for each parameter. 

Run the fastp shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/raw`. 

```
sh fastp.sh <path_to_raw_sequences>
```
If you do not enter the path to the raw sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.
Trimmed reads will be saved in `/data/trimmed_sequences`.

## FASTQC TRIMMED READS 
We next run fastQC on all our trimmed reads to check our trimming parameters. We will run the same shell file and job file we ran the first time, just using a different target directory.

### Run FastQC
Go to the directory containing your job files. The shell file below, and the job file that it modifies and submits to Hydra, `fastqc.job` should both be here.  Your trimmed reads should already be in `/data/trimmed_sequences`. 

Run the fastQC shell script, including the path to the directory containing your trimmed files. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
```
sh fastqc_genomeskimming.sh <path_to_raw_sequences>
```
If you do not enter the path to the trimmed sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.

### Download FastQC of Trimmed Reads
Download the directory containing the fastQC results (it should be `/data/trimmed_sequences/fastqc_analyses`) to your computer. Open the html files using your browser to examine how well you trimming parameters worked. Interpreting fastQC results can be tricky, and will not be discussed here. See LAB staff or others familiar with fastQC for help. You may need to retrim using different parameters, depending upon the quality of the trimmed reads.

## SPAdes 
We are going to run SPAdes on all our trimmed paired and unpaired reads. SPAdes error-corrects all reads, then performs a de-novo assembly using both pair-end and single-end reads and outputs a set of contigs. 

### Run SPAdes 
Run the SPAdes shell script, including the path to the directory containing your trimmed read files. For most, it should be something like: `/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
NOTE: Make sure you do not put a forward slash at the end of the path. As above, if you tab-to-complete, it automatically adds a forward slash at the end. Remove it.
```
sh spades_multi_hydra.sh <path_to_trimmed_sequences>
```
If you do not enter the path to the trimmed sequences in the command, or enter a path to a directory that does not contain `fastq.gz` files, you will get the following error "Correct path to read files not entered (*.fastq.gz)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.

Your results should be in `/scratch/genomics/<USERNAME>/<PROJECT>/data/results/spades`. The results for each sample will be in a separate folder, named with the sample name. 

### Copy and Rename SPAdes Contigs
`SPAdes` recommends using the `contigs.fasta` file as resulting sequences, and saves these contigs in `<PROJECT>/data/results/spades/<SAMPLE>` as a generic `contigs.fasta` file. This makes it difficult to batch transfer these files, because there is no sample differentiation. To fix this, run this shell script which copies all `contigs.fasta ` files into a new directory `<PROJECT>/data/results/spades_contigs` and renames them with their sample name. I also copy the trimmed reads that have been error-corrected by SPAdes into a new directory `<PROJECT>/data/results/error_corrected_reads`.

Run `rename_spades_contigs.sh`, including the path to the SPAdes results directory, usually: `/scratch/genomics/<USERNAME>/<PROJECT>/data/results/spades`.
```
sh rename_spades_contigs.sh <path_to_spades_results>
```
If you do not enter the path to the spades results directory in the command, or enter a path to a directory that does not contain sample-specific directories containing `contigs.fasta` files, you will get the following error "Correct path to SPAdes results not entered". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors.

## MitoFinder
We will run MitoFinder using the contigs that result from the SPAdes assembly. These assemblies may be more likely to contain the entire mitochondrial genome, because unlike MitoFinder, SPAdes uses trimmed single-end reads in addition to paired-end reads, and therefore utilizes more reads in its assembly. MitoFinder also runs more efficiently with contigs as inputs because it does not need to perform an assembly step.

### Run MitoFinder using SPAdes Contigs
MitoFinder requires a mitochondrial genome database in GenBank (.gb) format. This pipeline currently uses a metazoan mitochondrial reference database downloaded from GenBank. If you would like to use a different database follow the directions here: https://github.com/RemiAllio/MitoFinder/blob/master/README.md#how-to-get-reference-mitochondrial-genomes-from-ncbi to make your own, and save it in your home directory. You will have to alter `mitofinder_annotate_spades.job` to point to the location of your database.

Run the  MitoFinder for annotating spades contigs shell script, including the path to the directory containg your SPAdes contigs files and the number representing the genetic code you wish to use. For most, the it should be something like: `/scratch/genomics/<USERNAME>/<PROJECT>/data/results/spades/contigs`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebrate mitochondrial DNA). For other taxa, see the `.job ` file for a complete list. 
NOTE: Make sure you do not put a forward slash at the end of the path. If you use tab to complete, it automatically adds a forward slash at the end. Remove it.
```
sh mitofinder_annotate_spades.sh <path_to_spades_contigs>
```
If you do not enter the path to the SPAdes contigs in the command, or enter a path to a directory that does not contain `contigs.fasta` files, you will get the following error "Correct path to SPAdes contigs files not entered (*contigs.fasta)". You may get additional errors, but they should stem from an incorrect or missing path, so adding that path should fix these errors. If you don't include a number representing a genetic code, you will get the following error "Genetic code not entered (should be a number between 1 and 25)".

Results of these analyses are saved in `PROJECT/data/results/mitofinder`

### Move MitoFinder Final Results Directory
The most important information from a MitoFinder analysis is saved in the `<SAMPLE>_Final_Results` directory. Because this directory is found in each sample-specific results directory, downloading these diretories from many sample runs can be time-consuminug. To make downloading easier, here is a shell script that copies `<SAMPLE>_Final_Results` from all samples into a single `/data/results/mitofinder_final_results` directory. This script also copies the `.log` file for each sample into `/data/results/mitofinder_final_results`.

Run `copy_mitofinder_final_results.sh`, including the path to the MitoFinder results directory: `/data/results/mitofinder`.
```
sh copy_mitofinder_final_results.sh <path_to_mitofinder_results>
```

### Download Results
Finally, we download all the directories containing our results. There should be one for all MitoFinder results (`/data/results/mitofinder_final_results`) and one for SPAdes contigs (`/data/results/spades_contigs`). I typically also download the trimmed, SPAdes error-corrected reads (`/data/results/error_corrected_reads`). You may want to download additional files depending upon what you or your group decides to keep, but these are the immediately most important results.
