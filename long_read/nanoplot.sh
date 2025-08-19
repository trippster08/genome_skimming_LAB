#!/bin/sh

reads="$1"
read_type=$(basename ${reads} | sed 's/_reads$//')

data=${reads}/..
if [[ -z "$(ls ${reads}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

nanoplot_results=${data}/results/${read_type}_nanoplot_analyses/
mkdir -p ${nanoplot_results}

for x in ${reads}/*.fastq.gz ; do 
  sample=${x##*/}
  name=`echo ${sample%.fastq.gz}`
  if [ -f ${nanoplot_results}/${name}_NanoPlot-report.html ]; then
    echo "Nanoplot has already analyzed ${name}"
  elif [ -f logs/${name}_nanoplot_hydra.log ]; then
    if [ -f ${nanoplot_results}/${name}_nanoplot_hydra.log ]; then
      rm -r ${nanoplot_results}/${name} ${nanoplot_results}/${name}_nanoplot_hydra.log \
      logs/${name}_nanoplot_hydra.log
      mkdir -p ${nanoplot_results}/${name}
      qsub -o logs/${name}_nanoplot_hydra.log \
      -N ${name}_nanoplot \
      nanoplot_loop.job ${reads} ${sample} ${name} ${data} ${nanoplot_results}
    else  
      rm -r ${nanoplot_results}/${name} logs/${name}_nanoplot_hydra.log
      mkdir -p ${nanoplot_results}/${name}
      qsub -o logs/${name}_nanoplot_hydra.log \
      -N ${name}_nanoplot \
      nanoplot_loop.job ${reads} ${sample} ${name} ${data} ${nanoplot_results}
    fi
  else
    mkdir -p ${nanoplot_results}/${name}
    qsub -o logs/${name}_nanoplot_hydra.log \
    -N ${name}_nanoplot \
    nanoplot_loop.job ${reads} ${sample} ${name} ${data} ${nanoplot_results}
  fi
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
