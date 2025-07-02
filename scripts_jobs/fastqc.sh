#!/bin/sh

reads="$1"
read_type=$(basename ${reads})
results=${reads}/../results
data=${reads}/..
if [[ -z "$(ls ${reads}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${results}/${read_type}_fastqc_analyses

for x in ${reads}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.fastq.gz}`
  if [ -f ${results}/${read_type}_fastqc_analyses/${name}_*.html ]; then
    echo "QC for ${name} has already been performed"
  elif [ -f logs/${name}_fastqc_hydra.log ]; then
    rm logs/${name}_fastqc_hydra.log
    qsub -o logs/${name}_fastqc_hydra.log \
    -N ${name}_fastqc \
    fastqc_loop.job ${reads} ${sample} ${read_type}
  else
    qsub -o logs/${name}_fastqc_hydra.log \
    -N ${name}_fastqc \
    fastqc_loop.job ${reads} ${data} ${sample} ${read_type} ${name}
  fi
  sleep 0.1
done



# This script runs a fastqc analysis on multiple fastq sequences, either reads
# demultiplexed sequences or trimmed sequences that that have been output using
# either trimmomatic or fastp. 

# Raw sequences should be in PROJECT/data/reads/ and trimmed sequences should be
# PROJECT/data/trimmed_sequences/. For each sample file, it will output an html
# file that you should transfer to your local computer. Open this file with your
# browser and view the visual representations of your sample quality.
# It will also output a .zip file that contains text summaries of read quality.  
# See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
# with transferring files between Hydra and your computer.
