# Genome Skimming Pipeline for LAB
1. [Local Computer Configuration](#Local-Computer-Configuration) </br>
2. [Hydra Configuration](#Hydra-Configuration) </br>
  2.1. [Install conda and biopython](#Install-conda-and-biopython) </br>
  2.2. [Install conda packages](#Install-conda-packages) </br>
  2.3. [Project-specific directory](#Project-specific-directory) </br>
  2.4. [Transfer reads to hydra](#Transfer-reads-to-hydra) </br>
3. [`FastQC`Raw Reads](#FastQC-Raw-Reads) </br>
  3.1. [Run FastQC](#Run-Fastqc) </br>
  3.2. [Download Results](#Download-Results) </br>    
4. [Trimming and Filtering Raw Reads](#Trimming_and_Filtering_Raw_Reads) </br>
5. [`FastQC`Trimmed Reads](#FastQC-Trimmed-Reads) </br>
  5.1. [Run FastQC](#Run-Fastqc) </br>
  5.2. [Download Results](#Download-Results) </br>
6. [MitoFinder](#MitoFinder) </br>
  6.1. [Concatenate single-end reads](#Concatenate-single-end-reads) </br>
  6.2. [Run MitoFinder](Run-MitoFinder) </br>
7. [SPAdes](#SPAdes) </br>
  7.1. [Run SPAdes](#Run-SPAdes) </br>

This protocol is to analyze paired-end or single-read demultiplexed illumina
sequences for the purpose of recovering mitochondrial genomes from genomic DNA
libraries. This pipeline is designed to use hydra, Smithsonian's HPC for
`fastqc`, `trimmomatic`, `MitoFinder`, and `SPAdes`. The pipeline assumes you have a
current hydra account and are capable of accessing the SI network, either
in person or through VPN. Our pipeline is specifically written for MacOS,
but is compatible with Windows. See 
https://confluence.si.edu/display/HPC/Logging+into+Hydra to see differences 
between MacOS and Windows in accessing Hydra.

## Local Computer Configuration 
Make a project directory, and mulitple subdirectories on your local computer.
Make this wherever you want to store your projects. Hydra is not made for
long-term storage, so raw sequences, jobs, results, etc should all be kept
here when your analyses are finished. Although it is not necessary, I use the
same directory pattern locally as I use in Hydra. 

Make sure to replace "PROJECT" with your project name throughout.
```
mkdir -p <PROJECT>/data/raw <PROJECT>/data/trimmed_sequences \
<PROJECT>/jobs <PROJECT>/data/results
```
Your raw reads need to be in `<PROJECT>/data/raw`

## Hydra Configuration 
Open the terminal app and log onto Hydra. You will need your hydra account
  password.
```
ssh USERNAME@hydra-login01.si.edu
```
  or
```
ssh USERNAME@hydra-login02.si.edu
```
### Install Conda and Biopython 
All the programs we will use in our analyses will be run as conda packages.
This section and the next ("Install conda packages") will only need to be run
the first time you run this pipeline. For subsequent analyses, go directly to
the following step where you set up project-specific directories.

Get the latest version of `miniconda`.
```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```
Run the file you just downloaded. Select "yes" to all options, and install to
your home directory.
```
sh Miniconda3-latest-Linux-x86_64.sh
```
Install `biopython`
```
conda install -c conda-forge biopython
```
Add bioconda channel and other channels needed for bioconda. Run this in the
order shown (this sets priority, with highest priority last).
```
conda config --add channels defaults
```
```
conda config --add channels bioconda
```
```
conda config --add channels conda-forge
```
To run `miniconda` packages on Hydra, you need to set up a module file
```
mkdir ~/modulefiles2 
```
```
cd ~/modulefiles 
```
```
nano miniconda
```
Enter into the new text file the following text (both lines). Remember to
substitute your username for "USERNAME"
```
#%Module1.0
prepend-path PATH /home/<USERNAME>/miniconda3/bin
```
### Install Conda Packages 
Here we install the programs we may need in our analyses. We are going to run
and install them as conda enviroments. 

Install `FastQC`as a conda envirnoment.
```
conda create -n fastqc fastqc
```
Install `Trimmomatic` as a conda environment
```
conda create -n trimmomatic trimmomatic
```
Install `fastp` as a conda environment
```
conda create -n fastp fastp
```
Install `GetOrganelle` as a conda environment
```
conda create -n getorganelle getorganelle
```

Install `SPAdes` as a conda environment
```
conda create -n spades spades
```

### Project-specific Directory 
Go to the the directory assigned to you for short-term storage of large
data-sets. Typically this will be `/scratch/genomics/<USERNAME>`. Replace USERNAME with your hydra username.
```
cd /scratch/genomics/<USERNAME>
```
Make a project-specific directory, with the following subdirectories:
`/jobs` `/data/results` `/data/raw`. -p allows you to create subdirectories and
any parental ones that don't already exist (in this case, PROJECT). I use the
same directory pattern here as on my local computer, to lessen confusion.
Again, replace PROJECT with your project name.
```
mkdir -p <PROJECT>/data/raw <PROJECT>/data/trimmed_sequences \
<PROJECT>/jobs <PROJECT>/data/results
```
### Transfer Reads to Hydra 
Your raw reads need to be copied into `<PROJECT>/data/raw`. I usually use scp or
filezilla for file transfers. 
See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
with transferring files between Hydra and your computer. I usually use scp
or filezilla.

## `FastQC`Raw Reads

We are going to run `FastQC`on all our reads to check their quality and help
determine our trimming parameters. Because we do not want to have to create
a separate job file for each read file, I have set up a single shell file that
submits a `FastQC`job file for each read, running them simultaneously. 

### Run FastQC
Open the terminal app and log onto Hydra. You will need your hydra account
password.

```
ssh USERNAME@hydra-login01.si.edu
```
 or
```
ssh USERNAME@hydra-login02.si.edu
```

Go to the directory containing your job files.  If you followed this pipeline,
that should be `<PROJECT>/jobs`. The shell file below, and the job file that it
modifies and submits to Hydra, "fastqc_multi.job" should both be
here.  Your raw reads should already be in `<PROJECT>/data/raw`.  I usually use
scp or filezilla for file transfers. 
See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
with transferring files between Hydra and your computer. 

After the shell file, include the path to the directory your read files are
in. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/raw`. 
NOTE: Make sure you do not put a forward slash at the end of the path. If you
use tab to complete, it automatically adds a forward slash at the end. Remove
it.

Run the shell script.
```
sh fastqc_multi_hydra.sh <path_to_raw_sequences>
```
### Download Results

Download the directory containing the `fastqc`results (it should be
`/scratch/<USERNAME>/<PROJECT>/data/raw/fastqc_analyses`, but may be different for you)
to your computer. I usually use scp or filezilla for file transfers. 
See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
with transferring files between Hydra and your computer.

Open the html files using your browser to examine your read quality.

Interpreting `fastqc`results can be tricky, and will not be discussed here. See
LAB staff or others familiar with `fastqc`for help.

## Trimming and Filtering Raw Reads

We are going to run trim all our reads to remove poor quality basepairs and
residual adapter sequence using either `Trimmomatic` or `fastp`, depending upon
your preferences. The differences between the two have not been fully
evaluated, so I do not have a current recommendation. `fastp` is 
significantly faster while trimming similarly to `Trimmomatic`. I have found
that `fastp` does filter and trim more aggressviely using the default values (i.e. you
end up with fewer and shorter trimmed sequences), so the quality filtering parameters may
need to be evaluated further. One advantage is that both R1 and R2 unpaired
trimmed reads (reads for which the sequences in one direction did not pass
quality filtering) can be saved into the same file, so there is no need for
concatenation before using trimmed reads in `GetOrganelle` or `MitoFinder`)

Because we do not want to have to create a separate job file for each read
file, I have set up a single shell file that submits a `FastQC` job file for
each read, running them simultaneously. 

Trimmomatic requires an illumina adapter input fasta to search for and remove
adapters in the sequence. `fastp` does not require an illumina adapter, but you
can supply one for better adapter trimming, and we have here. LAB uses two
types of adapters, itru and nextera. Because most of the genome-skimming
library prep so far has been using the itru adapters, I only have a fasta file
for these. It is called `itru_adapters.fas`, and this is included in the Genome
Skimming pipeline.
I save the adapter fasta file in `/scratch/genomics/<USERNAME>/primers`. If you
save it somewhere else, you need to change the path to the primer fasta file
in the shell script: `fastp_genomeskimming_multi_hydra.sh`

Go to the directory containing your job files.  If you followed this pipeline,
that should be `<PROJECT>/jobs`. The shell file below, and the job file that it
modifies and submits to Hydra, `fastqc_multi.job` should both be
here.  Your raw reads should already be in `<PROJECT>/data/raw`.  I usually use
scp or filezilla for file transfers. 
See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
with transferring files between Hydra and your computer. 

Based on the length and quality of your reads (as determined by `FastQC`), you
may want to edit the fastp or trimmomatic job. 

Open the terminal app and log onto Hydra. You will need your hydra account
password.
```
ssh USERNAME@hydra-login01.si.edu
```
 or
```
ssh USERNAME@hydra-login02.si.edu
```
After the shell file, include the path to the directory your read files are
in. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/raw`. 
NOTE: Make sure you do not put a forward slash at the end of the path. If you
use tab to complete, it automatically adds a forward slash at the end. Remove
it.

Run `fastp` shell script
```
sh fastp_multi_hydra.sh <path_to_raw_sequences>
```
or run `Trimmomatic` shell script
```
sh trimmomatic_multi_hydra.sh <path_to_raw_sequences>
```
Trimmed reads will be saved in `<PROJECT>/data/trimmed_sequences`.

## FASTQC TRIMMED READS 
We are going to run `FastQC` on all our trimmed reads to check our trimming
parameters. We will run the same shell file and job file we ran the first
time, just using a different target directory.

### Run FastQC
Open the terminal app and log onto Hydra. You will need your hydra account password.
```
ssh USERNAME@hydra-login01.si.edu
```
 or
```
ssh USERNAME@hydra-login02.si.edu
```
Go to the directory containing your job files. The shell file below, and the
job file that it modifies and submits to Hydra, `fastqc_multi.job` should both
be here.  Your trimmed reads should already be in
`<PROJECT>/data/trimmed_sequences`. 
See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
with transferring files between Hydra and your computer. 

After the shell file, include the path to the directory your read files are
in. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
NOTE: Make sure you do not put a forward slash at the end of the path. If you
use tab to complete, it automatically adds a forward slash at the end. Remove
it.
```
sh fastqc_multi_hydra.sh <path_to_trimmed_sequences>
```
### Download Results
Download the directory containing the `FastQC`results (it should be
`/scratch/<USERNAME>/<PROJECT>/data/trimmed_sequences/fastqc_analyses`, but may be
different for you) to your computer. 

Open the html files using your browser to examine how well you trimming
parameters worked.

## MitoFinder

We are going to run `MitoFinder` on all our paired-end trimmed reads to try to
find full mitochondrial genomes. I have set up a single shell file that
submits a `MitoFinder` job file for each sample, and runs them simultaneously. 

### Concatenate single-end reads 
`MitoFinder` can use unpaired (single-end or SE) reads, but it only allows one SE fastq file, so we need to concatenate our R1_SE and R2_SE if we used `Trimmomatic` to trim and filter
out raw reads.

Go to the directory containing your job files. If you followed this pipeline,
that should be `<PROJECT>/jobs`. The shell file below, and the job file that it
modifies and submits to Hydra, `spades_multi.job` should both be
here. Copy them here if need be. 
See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
with transferring files between Hydra and your computer.
Trimmed read files should be in `<PROJECT>/data/trimmed_sequences`

I have a shell script that will concatenate all the trimmed R1.SE and R2.SE 
files in the trimmed_sequences directory, and rename them. If you trimmed with
`fastp` instead of `Trimmomatic`, you don't need to concatenate. After the shell
file, give the path to the directory holding the SE files, typically
`/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
NOTE: Make sure you do not put a forward slash at the end of the path. If you
tab-to-complete, it automatically adds a forward slash at the end. Remove
it.
Concatenate SE files
```
sh concatenate_SE_reads.sh <path_to_trimmed_sequences>
```
Check to make sure the concatenated files exist
```
ls -lhrt ../data/trimmed_sequences
```

### Run MitoFinder
Open the terminal app and log onto Hydra. You will need your Hydra account
password.
```
ssh USERNAME@hydra-login01.si.edu
```
or
```
ssh USERNAME@hydra-login02.si.edu
```
Go to the directory containing your job files. If you followed this pipeline,
that should be `<PROJECT>/jobs`. The shell file below, and the job file that it
modifies and submits to Hydra, `mitofinder_multi.job` should both be
here. Copy them here if need be. 
See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
with transferring files between Hydra and your computer. I usually use scp
or filezilla.

After the shell file, include the path to the directory your read files are
in. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
NOTE: Make sure you do not put a forward slash at the end of the path. If you
use tab to complete, it automatically adds a forward slash at the end. Remove
it.

```
sh mitofinder_multi_hydra.sh <path_to_trimmed_sequences>
```
You don't appear to have the ability to choose where to put the results folder, and
MitoFinder puts them where they are run from, in this case, the jobs directory.
The results for each sample will be in a separate folder, named with the sample name. 
Transfer these results folders to your local computer. 

## SPAdes 

We are going to run `SPAdes` on all our paired-end trimmed reads where we were
not able to get mtgenomes using `MitoFinder`. `SPAdes` will perform a de-novo
assembly and will output a set of contigs. I have set up a shell file that
will submit a job file for each sample, running them simultaneously.

Open the terminal app and log onto Hydra. You will need your Hydra account
password.
```
ssh USERNAME@hydra-login01.si.edu
```
or
```
ssh USERNAME@hydra-login02.si.edu
```
### Run SPAdes 

After the shell file, include the path to the directory your read files are
in. For most, it should be something like: 
`/scratch/genomics/<USERNAME>/<PROJECT>/data/trimmed_sequences`. 
NOTE: Make sure you do not put a forward slash at the end of the path. As 
above, if you tab-to-complete, it automatically adds a forward slash at the
end. Remove it.

```
sh spades_multi_hydra.sh <path_to_trimmed_sequences>
```
Your results should be in
`/scratch/genomics/<USERNAME>/<PROJECT>/data/results/spades`. The results for
each sample will be in a separate folder, named with the sample name. 
Transfer these results folders to your local computer. 
