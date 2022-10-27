#!/bin/sh

cd ../data/trimmed_sequences

mkdir fastqc_analyses

 for x in *.fastq.gz ; do 
  base=`echo ${x} | cut -d "_" -f 1,2,3,4,5`

  fastqc \
  -o fastqc_analyses \
  ${base}
done


# This script runs a fastqc analysis on multiple fastq sequences that have 
# been trimmed with trimmomatic. It assumes the file names are the format used
# in this pipeline as the output from trimmomatic, for example:
# "SampleName_Barcode_R1_PE_trimmed.fastq.gz"
# All files should be in PROJECT/data/trimmed_sequences. For each
# sample file, it will output an html file that you should transfer to your 
# local computer. Open this file with your browser and view the visual
# representations of your sample quality.
# It will also output a .zip file that contains text summaries of read quality.  
# See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
# with transferring files between Hydra and your computer.
