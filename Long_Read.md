# Nanopore Long-Read Genome Skimming
1. [Local Computer Configuration](#local-computer-configuration) </br>
2. [Hydra Configuration](#hydra-configuration) </br>
  2.1. [Log into Hydra](#log-into-hydra) </br>
  2.2. [Project-specific directory](#project-specific-directory) </br>
  2.3. [Transfer files to hydra](#transfer-files-to-hydra) </br>
3. [Running the Pipeline](#running-the-pipeline) </br>
4. [QC Raw Reads](#qc-raw-reads) </br>
5. [Filter and Trim](#filter-and-trim) </br>
6. [Assembly](#assembly) </br>
7. [Error Correction](#error-correction) </br>
8. [Short Read Polishing](#short-read-polishing) </br>
9. [Annotation](#annotation)
10. [Mapping Reads](#mapping-reads) </br>
11. [Download Results](#download-results) </br>

This protocol is to analyze [Oxford Nanopore](https://nanoporetech.com/) long read sequences for the purpose of recovering mitochondrial genomes from genomic DNA libraries. This pipeline is designed run multiple samples simultanteously on [Hydra](https://confluence.si.edu/display/HPC/High+Performance+Computing), Smithsonian's HPC, using [Flye](https://github.com/mikolmogorov/Flye) for assembly, [Medaka](https://github.com/nanoporetech/medaka) for sequence correction, [MitoFinder](https://github.com/RemiAllio/MitoFinder) for mitochondrial genome detection from assemblies, [MITOS](https://gitlab.com/Bernt/MITOS/) and [MitoFinder](https://github.com/RemiAllio/MitoFinder) for mitogenome annotation, and [Minimap2](https://github.com/lh3/minimap2) for mapping reads to mitogenomes. The pipeline assumes you have a current hydra account and are capable of accessing the SI network, either in person or through VPN. Our pipeline is specifically written for MacOS, but is compatible with Windows. See [Hydra on Windows PCs](https://confluence.si.edu/display/HPC/Logging+into+Hydra) for differences between MacOS and Windows in accessing Hydra.

Much of this pipeline is run similarly to the short-read version, therefore much of the directions below are identical. You do not need to read the short-read directions found in the [README.md](xxxxxxx).

## Local Computer Configuration 
Make a project directory, and multiple subdirectories on your local computer. Make this wherever you want to store your projects. Hydra is not made for long-term storage, so raw sequences, jobs, results, etc should all be kept here when your analyses are finished. Although it is not necessary, I use the same directory pattern locally as I use in Hydra. 

Make sure to replace "PROJECT" with your project name throughout.
```
mkdir -p PROJECT/data/raw PROJECT/jobs
```
Your raw reads should be in `data/raw/`. 

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
Download the pipeline to jobs/ in your Hydra account using `wget`. This downloads a compressed file that contains all job files (\*.job), and shell scripts (\*.sh) necessary for your analysis.
```
wget https://github.com/trippster08/genome_skimming_LAB/archive/refs/heads/main.zip
```
Unzip the pipeline, and move all the job and shell script files from your newly unzipped directory into the job directory. Delete the now-empty pipeline directory and zipped download. 
```
unzip main.zip

mv genome_skimming_LAB-main/scripts_jobs/* genome_skimming_LAB-main/extra_scripts/* genome_skimming_LAB-main/long_read/* jobs/
rm -r genome_skimming_LAB-main main.zip

```
Your raw reads should be copied into `data/raw/`. Download to your local computer and use scp or filezilla to upload to `data/raw/`. See [Transferring Files to/from Hydra](https://confluence.si.edu/pages/viewpage.action?pageId=163152227) for help with transferring files between Hydra and your computer.

## Running the Pipeline
This pipeline is designed to run each program on multiple samples simultaneously. For each program, the user runs a shell script that includes a path to the directory containing your input files. This shell script creates and submits a job file to Hydra for each sample in the targeted directory. After transferring files to Hydra, the user should navigate to their jobs directory, which contains both job files and shell scripts, typically `/scratch/genomics/USERNAME/PROJECT/jobs/`. All shell scripts should be run from this directory. Log files for each submitted job are saved in `jobs/logs/`. 

Go to the jobs folder before running the scripts described below.
```
cd jobs/
```

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
The results of these analyses are saved in `data/results/nanpore_analyses/` and `data/results/toulligqc_analyses`

## Filter and Trim
We next trim adapter sequences and poor quality ends, as well as filter short and poor quality reads using two programs, [Dorado](https://github.com/nanoporetech/dorado/) and [Chopper](https://github.com/wdecoster/chopper/) 
### Remove Adapters with Dorado
Dorado is a program for analyzing Oxford Nanopore reads. It can demultiplex indices, call basepairs from Raw data, correct errors, and trim adapters. We will be using if for trimming adapters.  Reads are output into `data/trimmed_reads`. 
```
sh dorado.sh path_to_raw_sequences
```
### Quality Trim and Filter with Chopper
Chopper is a new implementation of the depreciated [NanoFilt](https://github.com/wdecoster/nanofilt). We will use it to remove any reads shorter than 100 bp and reads that have an average quality score less than 8. Chopper can also crop ends (either a fixed amount or based on quality score), can extract high-quality reads from full reads, and can split reads into high- and low-quality subreads. Output is saved in `data/filtered_reads`.
```
sh chopper.sh path_to_dorado_trimmed_sequences
```
## Assembly
We assemble trimmed and filtered reads using [Flye](https://github.com/mikolmogorov/Flye). Flye is a de novo long-read assembler. The fly_loop.job will output two sets of assemblies, one unedited, and one winnowed down to only include contigs that are sized appropriately for mitogenomes (1000-25000 bp) to reduce computation effort in mitogenome identification. Assembly results (fasta of contigs, assembly graph and assembly info) will be saved in `data/results/flye_assembiles/` as "SAMPLENAME_flye_assembly" "SAMPLENAME_flye_assembly_mitofiltered".
```
sh flye.sh path_to_trimmed_filtered_sequences
```
## Error Correction
We will error-correct (also called polishing) our assemblies using the program [Medaka](https://github.com/nanoporetech/medaka). Medaka uses trimmed and filtered reads against a reference (in our case, the contigs assembled by Flye). In general, this should reduce our sequencing error from ~0.3% from our Flye assemblies to ~0.04%. Medaka needs both the path to your filtered and trimmed reads as well as the path to your Flye assemblies. Medaka-corrected assemblies are saved to `results/medaka_corrected_assemblies`.
```
sh medaka.sh path_to_flye_assemblies path_to_trimmed_filtered_reads
```
## Short Read Polishing
If you also have short reads, you can polish your corrected assemblies using Illumina short reads and the program [NextPolish](https://github.com/Nextomics/NextPolish). Polishing your short reads can reduce your error rates furthur, from ~0.04% to 0.0001%. Nor NextPolish you need the path to your Medaka-corrected assemblies and the path to your trimmed Illumina short reads.  The short-read samples should have identical names to their long-read partners.
```
sh nextpolish.sh path_to_medaka_corrrected_assemblies path_to_trimmed_illumina_reads
```
## Annotation
We identify potential mitogenomes from corrected (and polished, if available) "mitofiltered" assemblies using MitoFinder, then annotate those identified mitogenomes using MitoFinder and MITOS 

Identify and Annotate medaka-corrected assemblies using MitoFinder. As with MitoFinder in the Illumina analyses, the shell script must be followed by the path to the Medata-corrected assemblies, the number representing the genetic code you wish to use, and the reference database to use. For most, the path should be something like: `/scratch/genomics/USERNAME/PROJECT/data/results/medaka_corrected_assemblies/`. The genetic code will most likely be either "2" (for vertebrate mitochondrial DNA) or "5" (for invertebrate mitochondrial DNA). For other taxa, see the `.sh` or `.job ` file for a complete list of genetic codes available.  
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
Analysis time is highly dependent on the size of the reference database used, so if possible it is recommended you use a taxon-specific one instead of "Metazoa".
MitoFinder results will be saved in `results/mitofinder_results/SAMPLENAME_mitofinder_medaka_Final_Results/`.
```
sh mitofinder_annotate_medaka.sh path_to_medaka_corrrected_assemblies
```
Identify and Annotate shortread-polished assemblies using MitoFinder. As with other MitoFinder analyses, the shell script must be followed by the path to the polished assemblies, the number representing the genetic code you wish to use, and the reference database to use. For most, the path should be something like: `/scratch/genomics/USERNAME/PROJECT/data/results/nexpolished_assemblies/`.

MitoFinder results will be saved in `results/mitofinder_results/SAMPLENAME_mitofinder_polished_Final_Results/`.
```
sh mitofinder_annotate_polished.sh path_to_polished_assemblies
```
Annotate assemblies from MitoFinder using MITOS. MitoFinder assemblies can be either corrected or polished, depending upon the path selected. Results will be saved in `results/mitos_results/SAMPLENAME_mitos_mitofinder/`.
```
sh mitos_annotate_mitofinder.sh path_to_mitofinder_final_results
```

## Mapping Reads
We can examine read coverage by mapping our Nanopore Reads to our finished assemblies using [Minimap2}](https://github.com/lh3/minimap2). Minimap2 normally creates a SAM files. However, we would prefer a BAM file (a binary version of a SAM file that usually are smaller and more efficient) that also only contains mapped reads, so we modify our bowtie2 output using samtools to output your resulting Minimap2 BAM file to `data/results/minimap_results/`. 
Run the shell script for minimap, followed by the path to your mitochondrial-identified contigs (typically your MitoFinder results), and the path to your trimmed and filtered reads.
```
sh minimap.sh path_to_mitofinder_results path_to_filtered_reads
```
## Download Results
Finally, download your results of interest. The main three directories to download would be `results/MitoFinder_results/`, `results/MITOS_results/`, and `results/Minimap2_results/`.  These directories contain all the files you need for evaluation of your mitogenomes. You may want to download additional files depending upon what you or your group need for futher investigation, or what you decide to keep for archival purposes.