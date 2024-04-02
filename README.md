# Genome Skimming Pipeline for LAB
1. [Local Computer Configuration](#local-computer-configuration) </br>
2. [Hydra Configuration](#hydra-configuration) </br>
  2.1. [Log into Hydra](#log-into-hydra) </br>
  2.2. [Project-specific directory](#project-specific-directory) </br>
  2.3. [Transfer files to hydra](#transfer-files-to-hydra) </br>
3. [Running the Pipeline](#running-the-pipeline) </br>
4. [FastQC Raw Reads](#fastqc-raw-reads) </br>
  4.1. [Run FastQC](#run-fastqc) </br>
  4.2. [Download Raw-Reads FastQC Results](#download-raw-reads-fastqc-results) </br>    
5. [Trimming and Filtering Raw Reads with  fastp](#trimming-and-filtering-raw-reads-with-fastp) </br>
6. [FastQC Trimmed Reads](#fastqc-trimmed-reads) </br>
  6.1. [Run FastQC](#run-fastqc) </br>
  6.2. [Download FastQC of Trimmed Reads](#download-fastqc-of-trimmed-reads) </br>
7. [GetOrganelle](#getorganelle) </br> 
  7.1. [Run GetOrganelle](#run-getorganelle) </br>
  7.2. [Copy and Rename GetOrganelle Contigs](#copy-and-rename-getorganelle-contigs) </br>
8. [MitoFinder](#mitofinder) </br>
  8.1. [Run MitoFinder using GetOrganelle Contigs](#run-mitofinder-using-getorganelle-contigs) </br>
  8.2. [Copy MitoFinder Final Results Directory](#copy-mitofinder-final-results-directory) </br>
9. [Mitos](#mitos)
10. [Map Reads to Reference](#map-reads-to-reference) </br>
  10.1. [Bowtie2](#bowtie2)
11. [Download Results](#download-results) </br>

This protocol is to analyze paired-end or single-read demultiplexed illumina sequences for the purpose of recovering mitochondrial genomes from genomic DNA libraries. This pipeline is designed to use [Hydra](https://confluence.si.edu/display/HPC/High+Performance+Computing), Smithsonian's HPC, to run [fastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), [fastp](https://github.com/OpenGene/fastp), [GetOrganelle](https://github.com/Kinggerm/GetOrganelle), [MitoFinder](https://github.com/RemiAllio/MitoFinder), [MITOS](https://gitlab.com/Bernt/MITOS/), and [Bowtie2](https://github.com/BenLangmead/bowtie2). The pipeline assumes you have a current hydra account and are capable of accessing the SI network, either in person or through VPN. Our pipeline is specifically written for MacOS, but is compatible with Windows. See https://confluence.si.edu/display/HPC/Logging+into+Hydra to see differences between MacOS and Windows in accessing Hydra.

This protocol currently includes methods to quality and adapter trim and filter raw reads, error-correct and assemble trimmed reads, and annotate assemblies. It does not yet include what to do with your assembled mitogenome, including checking for compelete annotation, quality of assembly and annotation, submission to GenBank, etc. I hope to add many of these steps soon. You can download this entire repository, including all `.job` and `.sh` files using this link: [Genome Skimming @ LAB](https://github.com/trippster08/genome_skimming_LAB/archive/refs/heads/main.zip).

## Local Computer Configuration 
Make a project directory, and mulitple subdirectories on your local computer. Make this wherever you want to store your projects. Hydra is not made for long-term storage, so raw sequences, jobs, results, etc should all be kept here when your analyses are finished. Although it is not necessary, I use the same directory pattern locally as I use in Hydra. 

Make sure to replace "PROJECT" with your project name throughout.
```
mkdir -p PROJECT/data/raw PROJECT/jobs
```
Your raw reads should be in `PROJECT/data/raw` (or any directory meant to hold only raw read files). 
NOTE: As currently designed, this pipeline works best if raw data is `fastq.gz` formated, named in the default Illumina manner, with 5 elements (sample name, barcode number, lane number, read number, and "001") all separated by underscores (i.e. Sample1_S001_L001_R1_001.fastq.gz). However, the pipeline does work with reduced filenames. The required elements are a unique sample name (that contains no underscores) at the start of the filename, and read number (either R1 or R2) later in the filename, and all elements need to be separated by an underscore. Also, Hydra does not allow jobs names to start with a number, so if your sample names start with a number, change the name to add a letter (I usually use the initials of the researcher) before running this pipeline.

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
Go to the the directory assigned to you for short-term storage of large data-sets. Typically this will be `/scratch/genomics/USERNAME`. Replace USERNAME with your hydra username.
```
cd /scratch/genomics/USERNAME
```
Make a project-specific directory, with the following subdirectories: `jobs` and `data/raw`. -p allows you to create subdirectories and any parental ones that don't already exist (in this case, PROJECT). I use the same directory tree here as on my local computer, to lessen confusion. Again, replace PROJECT with your project name.
This pipeline is not dependent upon the directory tree shown, so you can set up your space differently, if you prefer. The only two directories that are required are `/data` and `/jobs` but you can name them whatever you like, and neither necessarily have to be in any particular place.This pipeline does create seveal new directories: `/data/trimmed_sequences`, `/data/results`, and within `/data/results` program-specific directories for those results, and `/jobs/logs`. If you don't want these directories created, or want them in different places, they can be changed in the shell scripts. 
```
mkdir -p PROJECT/data/raw PROJECT/jobs
```
### Transfer Files to Hydra 
You will need to transfer all the necessary files for this pipeline to your Hydra account. This includes raw read files (`*.fastq.gz`), job files (`*.job`), and shell scripts (`*.sh`).
Your raw reads should be copied into `PROJECT/data/raw`. Both job files and shell scripts should be copied into `PROJECT/jobs`. I usually use scp or filezilla for file transfers. See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help with transferring files between Hydra and your computer. 

## Running the Pipeline
This pipeline is designed to run each program on multiple samples simultaneously. For each program, the user runs a shell script that includes a path to the directory containing your input files. This shell script creates and submits a job file to Hydra for each sample in the targeted directory. After transeferring files to Hydra, the user should navigate to their jobs directory, which contains both job files and shell scripts, typcially `/scratch/genomics/USERNAME/PROJECT/jobs`. All shell scripts should be run from this directory. Log files for each submitted job are saved in `PROJECT/jobs/logs`. As mentioned earlier, while I find 
NOTE: Additional information for each program can be found in the `.job` file for each specific program. Included is program and parameter descriptions, including recommendations for alternative parameter settings. 

## fastQC Raw Reads
We first run fastQC on all our reads to check their quality and help determine our trimming parameters. 

### Run FastQC
Run the fastQC shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/USERNAME/PROJECT/data/raw`. 
```
sh fastqc_genomeskimming.sh path_to_raw_sequences
```
The results of these analyses are saved in `PROJECT/data/raw/fastqc_analyses`

### Download Raw-Reads FastQC Results
Download the directory containing the fastQC results (it should be `/data/raw/fastqc_analyses`) to your computer. Open the html files using your browser to examine your read quality. Interpreting fastQC results can be tricky, and will not be discussed here. See LAB staff or others familiar with fastQC for help.

## Trimming and Filtering Raw Reads with fastp
We are going to trim all our reads to remove poor quality basepairs and residual adapter sequence using fastp, a program that trims similarly to Trimmomatic (the trimming program we previously used), but is significantly faster. fastp also filters out poor-quality or exceptionally short reads. I have found that fastp does filter and trim more aggressviely using the similar parameters (i.e. you end up with slightly fewer and shorter trimmed sequences), so the quality filtering parameters may need to be evaluated further. One advantage is that both R1 and R2 unpaired trimmed reads (reads for which the sequence in one direction did not pass quality filtering) can be saved into the same file, so there is no need for concatenation before using trimmed reads in SPAdes.

fastp does not require an illumina adapter to remove adapter sequences, but you can supply one for better adapter trimming, and we use one here. LAB uses two types of adapters, itru and nextera. Because most of the genome-skimming library prep so far use the itru adapters, I have included a fasta file for these, called `itru_adapters.fas`. We can provide a nextera adapter file upon request. This pipeline currently points to a directory containing the itru adapter file, if you want to use your own adapter file, you will need to change the path following the command `--adapter_fasta` in `fastp.job`.

Based on the quality of your reads (as determined by fastQC), you may want to edit the parameters in  `fastp.job`. The job file contains descriptions and suggestions for each parameter. 

Run the fastp shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/USERNAME/PROJECT/data/raw`. 

```
sh fastp.sh path_to_raw_sequences
```
Trimmed reads will be saved in `/data/trimmed_sequences`.

## FASTQC TRIMMED READS 
We next run fastQC on all our trimmed reads to check our trimming parameters. We will run the same shell file and job file we ran the first time, just using a different target directory.

### Run FastQC
Go to the directory containing your job files. The shell file below, and the job file that it modifies and submits to Hydra, `fastqc.job` should both be here.  Your trimmed reads should already be in `/data/trimmed_sequences`. 

Run the fastQC shell script, including the path to the directory containing your trimmed files. For most, it should be something like: 
`/scratch/genomics/USERNAME/PROJECT/data/trimmed_sequences`. 
```
sh fastqc_genomeskimming.sh path_to_raw_sequences
```
The results of these analyses are saved in `PROJECT/data/trimmed_sequences/fastqc_analyses`

### Download FastQC of Trimmed Reads
Download the directory containing the fastQC results (it should be `/data/trimmed_sequences/fastqc_analyses`) to your computer. Open the html files using your browser to examine how well you trimming parameters worked. Interpreting fastQC results can be tricky, and will not be discussed here. See LAB staff or others familiar with fastQC for help. You may need to retrim using different parameters, depending upon the quality of the trimmed reads.

## GetOrganelle

We are going to run GetOrganelle on all our trimmed paired and unpaired reads. GetOrganelle performs a de-novo assembly using both pair-end and single-end reads (after xxxxx for mitochondrial reads - see [GetOrganelle Flowchart](https://github.com/Kinggerm/GetOrganelle?tab=readme-ov-file#getorganelle-flowchart) for a graphical representation of the assembly process) and outputs one or more mitochondrial contigs.

Before we run GetOrganelle for the first time, we need to download the program's `animal_mt` database. This only needs to be done one time for each database available through GetOrganelle (see the github website for a list of available databases).  Run this step directly from the command prompt. It will take about 30 seconds to run.

```bash
module load tools/conda
start-conda
conda activate /scratch/nmnh_lab/envs/genome_skimming/getorganelle_ksm
get_organelle_config.py -a animal_mt
```

### Run GetOrganelle
Run the GetOrganelle shell script, including the path to the directory containing your trimmed read files. For most, it should be something like: /scratch/genomics/USERNAME/PROJECT/data/trimmed_sequences.
```
sh getorganelle.sh path_to_trimmed_sequences
```
Your results should be in /scratch/genomics/USERNAME/PROJECT/data/results/getorganelle. The results for each sample will be in a separate folder, named with the sample name.

### Copy and Rename GetOrganelle Contigs
We are using the contigs file(s) as resulting sequences, and these are saved in PROJECT/data/results/getorganelle/SAMPLE as either a generic animal_mt.KXXX.complete.graphX.X.path_sequence.fasta or animal_mt.KXXX.scaffolds.graphX.X.path_sequence.fasta file (depending upon whether a complete mitochondrial genome was assembled or not). This makes it difficult to batch transfer these files, because there is no sample differentiation. To fix this, run this shell script which copies all "complete" or "scaffold" fasta files into a new directory PROJECT/data/results/getorganelle_contigs and renames them with their sample name. 

Run copy_getorganelle_scaffolds.sh, including the path to the GetOrganelle results directory, usually: /scratch/genomics/USERNAME/PROJECT/data/results/getorganelle.




We need a results folder for GetOrganelle: `data/results/getorganelle`. The GetOrganelle results for each paired set of reads (each hydra job) will be saved in a sample-specific directory. Unlike SPAdes, GetOrganelle creates that directory, so you don't need to create that (and GetOrganelle will stop and give you and error if you do create it). The contig file(s) that will be used in the next annotation step are named similar to either animal_mt.Kxxx.complete.graph1.x.path_sequence.fasta if GetOrgenelle found a complete mitogenome, or animal_mt.Kxxx.scaffolds.graph1.x.path_sequence.fasta if it found contigs that could not be circularized. 

Before we start GetOrganelle, we need to download the program's `animal_mt` database. This only needs to be done one time for each database available through GetOrganelle.

We're going to run this step directly from the command prompt rather than submitting a job. It will take about 30 seconds to run.

```bash
module load tools/conda
start-conda
conda activate /scratch/nmnh_lab/envs/genome_skimming/getorganelle_ksm
get_organelle_config.py -a animal_mt
```

Create and submit a GetOrganelle job for each set of trimmed fastq or fastq.gz read files.
A generic GetOrganelle job can be found here: [GetOrganelle.job](https://raw.githubusercontent.com/SmithsonianWorkshops/Genome_Skimming_Workshop_LAB_2024/main/job_files/getorganelle.job).

**Don't forget that you will need to create `data/results/getorganelle` first.**

## MitoFinder
We will run MitoFinder using the contigs that result from the GetOrganelle assembly. 

### Run MitoFinder using GetOrganelle Scaffolds
MitoFinder requires a mitochondrial genome database in GenBank (.gb) format. This pipeline allows you to chose either a metazoan mitochondrial reference database downloaded from GenBank or one of several taxon-specific databases culled from the full metazoan database. The current databases available are listed below. Please let me know if you would like a reference database for a taxonomic group other than these. If you would like to make your own database follow the directions here: [How To Get Reference Mitochondrial Genomes from NCBI](https://github.com/RemiAllio/MitoFinder/blob/master/README) and save it in your home directory. You will have to alter `mitofinder_annotate_spades.job` to point to the location of your database. Using a taxon-specific database signficantly reduces program runtime, so I recommend using one when able. As an example, changing from the full database (14000+ mitogenomes) to just molluscs (500 mitogenomes) reduces run time from  3 hours to  5 minutes.

Run the  MitoFinder for annotating spades contigs shell script, including the path to the directory containg your SPAdes contigs files, the number representing the genetic code you wish to use, and the reference database to use. For most, the path should be something like: `/scratch/genomics/USERNAME/PROJECT/data/results/spades/contigs`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebrate mitochondrial DNA). For other taxa, see the `.sh` or `.job ` file for a complete list of genetic codes available.  

The reference database should be one of: 
"Metazoa" (for the entire database)  
"Annelida"  
"Arthropoda"  
"Bryozoa"  
"Cnidaria"  
"Ctenophora"  
"Echinodermata"  
"Mollusca"  
"Nemertea"  
"Porifera"  
"Tunicata"  
"Vertebrata"  

```
sh mitofinder_annotate_spades.sh path_to_spades_contigs genetic_code reference_database
```
Results of these analyses are saved in `PROJECT/data/results/mitofinder`. The results for each sample will be in a separate folder, named with the sample name.

### Copy MitoFinder Final Results Directory
The most important information from a MitoFinder analysis is saved in the `SAMPLE_Final_Results` directory. Because this directory is found in each sample-specific results directory, downloading these directories from many sample runs can be time-consuminug. To make downloading easier, here is a shell script that copies `SAMPLE_Final_Results` from all samples into a single `/data/results/mitofinder_final_results` directory. This script also copies the `.log` file for each sample into `/data/results/mitofinder_final_results`.

Run `copy_mitofinder_final_results.sh`, including the path to the MitoFinder results directory: `/data/results/mitofinder`.
```
sh copy_mitofinder_final_results.sh path_to_mitofinder_results
```
## MITOS
MitoFinder does not always do a great job of annotating all the features present in your assembly, especially when there are not closely related taxa in the reference library. In these instances, MITOS can sometimes annotate genes that MitoFinder was not able to find. If you are only skimming from taxonomic groups that have a lot of representation in the reference library, this section is not needed. However, even with good references, MITOS can sometimes find some features, such as tRNAs and rRNAs, that MitoFinder does not, so I always run this, and only use as needed. For this pipeline, MITOS uses the contigs in the MitoFinder Final Results directory created in the previous step.  

Run the  MITOS for annotating MitoFinder contigs shell script, including the path to the directory containng your sample-specific MitoFinder directories files and the number representing the genetic code you wish to use. For most, the path should be something like: `/scratch/genomics/USERNAME/PROJECT/data/results/mitofinder_final_results/`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebrate mitochondrial DNA). For other taxa, see the `.sh` or `.job ` file for a complete list. 
```
sh mitos_annotate_mitofinder.sh path_to_mitofinder_final_results genetic_code
```

Results of these analyses are saved in `PROJECT/data/results/mitos_mitofinder`. The results for each sample will be in a separate folder, named with the sample name.


## Map Reads to Reference

### Bowtie2

## Download Results
Finally, we download all the directories containing our results. There should be one for all MitoFinder results (`/data/results/mitofinder_final_results`), one for SPAdes contigs (`/data/results/spades_contigs`), and one for MITOS results (`/data/results/mitos_mitofinder`). I typically also download the trimmed, SPAdes error-corrected reads (`/data/results/spades_error_corrected_reads`). You may want to download additional files depending upon what you or your group decides to keep, but these are the immediately most important results.
