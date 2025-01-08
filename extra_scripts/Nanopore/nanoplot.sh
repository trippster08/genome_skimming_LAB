#!/bin/sh

raw="$1"

if
  [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

for x in ${raw}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.fastq.gz}`
  mkdir -p ${raw}/nanoplot_analyses/${name}
  
  qsub -o logs/${name}_nanoplot_hydra.log \
  -N ${name}_nanoplot \
  nanoplot_loop.job ${raw} ${sample} ${name}

  sleep 0.1
done



# This script runs a fastqc analysis on multiple fastq sequences, either raw
# demultiplexed sequences or trimmed sequences that that have been output using
# either trimmomatic or fastp. 

# Raw sequences should be in PROJECT/data/raw/ and trimmed sequences should be
# PROJECT/data/trimmed_sequences/. For each sample file, it will output an html
# file that you should transfer to your local computer. Open this file with your
# browser and view the visual representations of your sample quality.
# It will also output a .zip file that contains text summaries of read quality.  
# See https://confluence.si.edu/pages/viewpage.action?pageId=163152227 for help
# with transferring files between Hydra and your computer.
