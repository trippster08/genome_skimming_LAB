#!/bin/sh

raw="$1"

if
  [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${raw}/fastqc_analyses

for x in ${raw}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.fastq.gz*}`

  qsub -o logs/${name}_fastqc.log \
  -N ${name}_fastqc \
  fastqc.job ${raw} ${sample}
done



# This script runs a fastqc analysis on multiple fastq sequences, either raw
# demultiplexed sequences or trimmed sequences that that have been output using
# either trimmomatic or fastp. It assumes the raw file names are
# in the format output by Illumina (for example 
# "SamplesName_Barcode_L001_R1_001.fastq.gz"), and the trimmed sequences are
# in the format used in this pipeline as the output from trimmomatic or fastp
# (for example: "SampleName_Barcode_R1_PE_trimmed.fastq.gz")
# Raw sequences should be in PROJECT/data/raw/ and trimmed sequences should be in
# PROJECT/data/trimmed_sequences/. For each sample file, it will output an html
# file that you should transfer to your local computer. Open this file with your
# browser and view the visual representations of your sample quality.
# It will also output a .zip file that contains text summaries of read quality.  
# See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
# with transferring files between Hydra and your computer.
