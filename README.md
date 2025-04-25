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
7. [Assemble Reads Using GetOrganelle](#assemble-reads-using-getorganelle) </br> 
8. [Annotation](#annotation) </br>
  8.1. [MitoFinder Using GetOrganelle Contigs](#mitofinder-using-getorganelle-contigs) </br>
  8.2. [MITOS Using GetOrganelle Contigs](#mitos-using-getorganelle-contigs) </br>
9. [Map Reads With Bowtie2](#map-reads-with-bowtie2) </br>
10. [Download Results](#download-results) </br>

This protocol is to analyze paired-end or single-read demultiplexed illumina sequences for the purpose of recovering mitochondrial genomes from genomic DNA libraries. This pipeline is designed run multiple samples simultanteously on [Hydra](https://confluence.si.edu/display/HPC/High+Performance+Computing), Smithsonian's HPC, using [fastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/), [fastp](https://github.com/OpenGene/fastp), [GetOrganelle](https://github.com/Kinggerm/GetOrganelle), [MitoFinder](https://github.com/RemiAllio/MitoFinder), [MITOS](https://gitlab.com/Bernt/MITOS/), and [Bowtie2](https://github.com/BenLangmead/bowtie2). The pipeline assumes you have a current hydra account and are capable of accessing the SI network, either in person or through VPN. Our pipeline is specifically written for MacOS, but is compatible with Windows. See [Hydra on Windows PCs](https://confluence.si.edu/display/HPC/Logging+into+Hydra) for differences between MacOS and Windows in accessing Hydra.

This protocol currently includes methods to quality and adapter trim and filter raw reads, error-correct and assemble trimmed reads, annotate assemblies, and map reads to those assemblies. It does not yet include what to do with your assembled mitogenome, including checking for compelete annotation, quality of assembly and annotation, submission to GenBank, etc. I hope to add many of these steps soon. You can download this entire repository, including all `.job` and `.sh` files using this link: [Genome Skimming @ LAB](https://github.com/trippster08/genome_skimming_LAB/archive/refs/heads/main.zip).

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
This pipeline is not dependent upon the directory tree shown, so you can set up your space differently, if you prefer. The only two directories that are required are `/data` and `/jobs` but you can name them whatever you like, and neither necessarily have to be in any particular place.This pipeline does create seveal new directories: `data/trimmed_reads/`, `data/results/`, and within `data/results/` program-specific directories for those results, and `jobs/logs/`. If you don't want these directories created, or want them in different places, they can be changed in the shell scripts. 
```
mkdir -p PROJECT/data/raw PROJECT/jobs
```
### Transfer Files to Hydra 
Download the pipeline to jobs/ in your Hydra account using `wget`. This downloads a compressed file that contains all job files (\*.job), and shell scripts (\*.sh) necessary for your analysis. This command downloads a compressed file that will become a directory upon unzipping. Don't forget to move into your jobs folder first: `cd PROJECT/jobs`.
```
wget https://github.com/trippster08/genome_skimming_LAB/archive/refs/heads/main.zip
```
Unzip the pipeline, and move all the \*.sh, \*.job, and \*.R files from your newly unzipped directory into the job directory and the primer folder into the main project directory. Delete the now-empty pipeline directory and zipped download. **NOTE**: The last command (`rm -r Metabarcoding_on_Hydra-main main.zip`) will not automatically start (but the rest will), so you need to hit enter or return once to complete.
```
unzip main.zip
mv genome_skimming_LAB-main/jobs/* .
mv genome_skimming_LAB-main/scripts/* .
rm -r genome_skimming_LAB-main main.zip

```
Your raw reads should be copied into `data/raw/`. Download to your local computer and use scp or filezilla to upload to `data/raw/`. See [Transferring Files to/from Hydra](https://confluence.si.edu/pages/viewpage.action?pageId=163152227) for help with transferring files between Hydra and your computer.

## Running the Pipeline
This pipeline is designed to run each program on multiple samples simultaneously. For each program, the user runs a shell script that includes a path to the directory containing your input files. This shell script creates and submits a job file to Hydra for each sample in the targeted directory. After transeferring files to Hydra, the user should navigate to their jobs directory, which contains both job files and shell scripts, typcially `/scratch/genomics/USERNAME/PROJECT/jobs/`. All shell scripts should be run from this directory. Log files for each submitted job are saved in `jobs/logs/`. 

NOTE: Additional information for each program can be found in the `.job` file for each specific program. Included is program and parameter descriptions, including recommendations for alternative parameter settings. 

## fastQC Raw Reads
We first run fastQC on all our reads to check their quality and help determine our trimming parameters. 

### Run FastQC
Run the fastQC shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/USERNAME/PROJECT/data/raw/`. 
```
sh fastqc.sh path_to_raw_sequences
```
The results of these analyses are saved in `data/raw/fastqc_analyses/`

### Download Raw-Reads FastQC Results
Download the directory containing the fastQC results (it should be `data/raw/fastqc_analyses/`) to your computer. Open the html files using your browser to examine your read quality. Interpreting fastQC results can be tricky, and will not be discussed here. See LAB staff or others familiar with fastQC for help.

## Trimming and Filtering Raw Reads with fastp
We are going to trim all our reads to remove poor quality basepairs and residual adapter sequences, and filter out poor-quality or exceptionally short reads using the program fastp.  

fastp does not require an illumina adapter to remove adapter sequences, but you can supply one for better adapter trimming, and we use one here. LAB uses two types of adapters, itru and nextera. Because most of the genome-skimming library prep so far use the itru adapters, I have included a fasta file for these, called `itru_adapters.fas`. We can provide a nextera adapter file upon request. This pipeline currently points to a directory containing the itru adapter file, if you want to use your own adapter file, you will need to change the path following the command `--adapter_fasta` in `fastp.job`.

Based on the quality of your reads (as determined by fastQC), you may want to edit the parameters in  `fastp.job`. The job file contains descriptions and suggestions for each parameter. 

Run the fastp shell script, including the path to the directory containing your raw read files. For most, it should be something like: 
`/scratch/genomics/USERNAME/PROJECT/data/raw/`. 

```
sh fastp.sh path_to_raw_sequences
```
Trimmed reads will be saved in `data/trimmed_reads/`.

## FASTQC TRIMMED READS 
We next run fastQC on all our trimmed reads to check our trimming parameters. We will run the same shell file and job file we ran the first time, just using a different target directory.

### Run FastQC
Go to the directory containing your job files. The shell file below, and the job file that it modifies and submits to Hydra, `fastqc.job` should both be here.  Your trimmed reads should already be in `data/trimmed_reads/`. 

Run the fastQC shell script, including the path to the directory containing your trimmed files. For most, it should be something like: 
`/scratch/genomics/USERNAME/PROJECT/data/trimmed_reads/`. 
```
sh fastqc.sh path_to_raw_sequences
```
The results of these analyses are saved in `data/trimmed_reads/fastqc_analyses/`

### Download FastQC of Trimmed Reads
Download the directory containing the fastQC results (it should be `data/trimmed_reads/fastqc_analyses/`) to your computer. Open the html files using your browser to examine how well you trimming parameters worked. Interpreting fastQC results can be tricky, and will not be discussed here. See LAB staff or others familiar with fastQC for help. You may need to retrim using different parameters, depending upon the quality of the trimmed reads.

## Assemble Reads Using GetOrganelle

We are going to run GetOrganelle on all our trimmed paired and unpaired reads. GetOrganelle performs a de-novo assembly using both pair-end and single-end reads (after filtering for mitochondrial reads - see [GetOrganelle Flowchart](https://github.com/Kinggerm/GetOrganelle?tab=readme-ov-file#getorganelle-flowchart) for a graphical representation of the assembly process) and outputs one or more mitochondrial contigs.

Before we run GetOrganelle for the first time, we need to download the program's `animal_mt` database. This only needs to be done one time for each database available through GetOrganelle (see the github website for a list of available databases).  Run this step directly from the command prompt. It will take about 30 seconds to run.

```bash
module load tools/conda
start-conda
conda activate /scratch/nmnh_lab/envs/genome_skimming/getorganelle_ksm
get_organelle_config.py -a animal_mt
```

### Run GetOrganelle
Run the GetOrganelle shell script, including the path to the directory containing your trimmed read files followed by organelle type (one of "embplant_pt", "other_pt", "embplant_mt", "embplant_nr", "animal_mt", "fungus_mt"). For most, it should be something like: `/scratch/genomics/USERNAME/PROJECT/data/trimmed_reads animal_mt`
```
sh getorganelle.sh path_to_trimmed_reads organelle
```
GetOrganelle results will be saved in `/scratch/genomics/USERNAME/PROJECT/data/results/getorganelle/`. The results for each sample will be in a separate direcotry, named with the sample name. Unfortunately, like many of the programs in this pipeline, the resultant mitochondrial contigs that will be used for annotation are generically named, with no sample name attached. Additionally, there are a lot of files and folders in the results directory that are extremely large and largely uneccesary to keep. To simplify annotation and downloading of the most essential information, the GetOrganelle job copies resultant mitochondrial contigs to `data/results/getorganelle_contigs/` while also prepending the sample name.  the getorganelle_contigs directory also contains three text files: 'getorganelle_repeats.txt', 'getorganelle_scaffolds.txt', and 'getorganelle_failures.txt'. 'getorganelle_scaffolds.txt' contains a list of all samples for which no contig was found. 'getorganelle_repeats.txt' contains a list of samples for which multiple contigs were found, all the same except for varying repeat regions attached to one end. These contigs are not copied to `data/results/getorganelle_contigs/`.  'getorganelle_scaffolds.txt' contains a list of all samples for which one or more mitochondrial contigs were found, but these contigs were not complete and circularizable. These contigs are copies to `data/results/getorganelle_contigs/` for annotation.

## Annotation
We will annotate our GetOrganelle mitochondrial genomes (both complete and incomplete) using two programs, [MitoFinder](https://github.com/RemiAllio/MitoFinder) and [MITOS](https://gitlab.com/Bernt/MITOS). 

### MitoFinder Using GetOrganelle Contigs
MitoFinder requires a mitochondrial genome database in GenBank (.gb) format. This pipeline allows you to chose either a metazoan mitochondrial reference database downloaded from GenBank or one of several taxon-specific databases culled from the full metazoan database. The current databases available are listed below. Please let me know if you would like a reference database for a taxonomic group other than these. If you would like to make your own database follow the directions here: [How To Get Reference Mitochondrial Genomes from NCBI](https://github.com/RemiAllio/MitoFinder/blob/master/README) and save it in your home directory. You will have to alter `mitofinder_annotate_getorganelle.job` to point to the location of your database. Using a taxon-specific database signficantly reduces program runtime, so I recommend using one when able. As an example, changing from the full database (14000+ mitogenomes) to just molluscs (500 mitogenomes) reduces run time from  3 hours to  5 minutes.

Run the  MitoFinder for annotating getorganelle contigs shell script, including the path to the directory containg your GetOrganelle contigs files, the number representing the genetic code you wish to use, and the reference database to use. For most, the path should be something like: `/scratch/genomics/USERNAME/PROJECT/data/results/getorganelle_contigs/`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebrate mitochondrial DNA). For other taxa, see the `.sh` or `.job ` file for a complete list of genetic codes available.  
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
sh mitofinder_annotate_getorganelle.sh path_to_getorganelle_contigs genetic_code reference_database
```
Results of these analyses are saved in `data/results/mitofinder_getorganelle/`. The results for each sample will be in a separate directory, named with the sample name. The most important information from a MitoFinder analysis is saved in a subdirectory called `SAMPLE_Final_Results`.  This directory does not contain any of the very large intermediate files that MitoFinder used during annotation, so it is a good target for downloading. However, because this subdirectory is found in each sample-specific results directory, downloading only this data from many sample runs can be time-consuminug. To make downloading easier, the job file has a script that copies `SAMPLE_Final_Results` for all samples to `data/results/mitofinder_results/`.  

### MITOS Using GetOrganelle Contigs
MitoFinder does not always do a great job of annotating all the features present in your assembly, especially when there are not closely-related taxa in the reference library. In these instances, MITOS can sometimes annotate genes that MitoFinder was not able to find. If you are only skimming from taxonomic groups that have a lot of representation in the reference library, this section is not needed. However, even with good references, MITOS can sometimes find some features, such as tRNAs and rRNAs, that MitoFinder does not, so I always run MITOS. As with MitoFinder, MITOS uses the contigs in the getorganelle_contigs directory.  

Run the MITOS for annotating getorganelle contigs shell script, including the path to the directory containing your getorganelle contigs and the number representing the genetic code you wish to use. For most, the path should be something like: `/scratch/genomics/USERNAME/PROJECT/data/results/getorganelle_contigs/`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebrate mitochondrial DNA). For other taxa, see the `.sh` or `.job ` file for a complete list. 
```
sh mitos_annotate_getorganelle.sh path_to_getorganelle_contigs genetic_code
```
Results of these analyses are saved in `data/results/mitos_getorganelle/`. The results for each sample will be in a separate sample-specific directory. The results are labeled generically, which no sample identification. Also in these sample-specific results directories are a lot of other very large files that you do not necessarily need to download. To make downloading and identifying MITOS results easier, the job file also copies all of the most important results into sample-specific directiries to `data/results/mitos_results/`. It also prepends the sample name to the copied results files. `mitos_results/` also contains a text file called 'mitos_failures.txt'. This file contains a list of the MITOS sample runs that did not result in mitogenome annotation.

## Map Reads With Bowtie2
One way to evaluate your assemblies is to map your trimmed reads to your contigs. We will map trimmed reads to our GetOrganelle mitochondrial contigs using the program [Bowtie2](https://github.com/BenLangmead/bowtie2).

Run the Bowtie2 shell script, including the path to the directory containing your getorganelle contigs and the path to the directory containing your trimmed sequences.

```
sh bowtie2_getorganelle.sh path_to_getorganelle_contigs path_to_trimmed_reads
```

Bowtie2 normally creates a SAM file, saving it (and other program-specific files) in a samples-specific directory in `/scratch/genomics/USERNAME/PROJECT/data/results/bowtie2_getorganelle/`. However, we would prefer a BAM file (a binary version of a SAM file that usually are smaller and more efficient) that also only contains assembled reads (i.e. reads from the mitochondrial genome), so we modify our bowtie2 output using samtools to output your resulting Bowtie2 BAM file to `data/results/bowtie2_results/`. 

## Download Results
Finally, we download all the directories containing our results. There should be one for GetOrganelle contigs (`data/results/getorganelle_contigs`), one for MitoFinder results (`data/results/mitofinder_results`), one for MITOS results (`data/results/mitos_results`) and one for Bowtie2 results (`data/results/bowtie2_results`). These directories contain all the files you need for evaluation of your mitogenomes. You may want to download additional files depending upon what you or your group decides to keep for archival purposes.
