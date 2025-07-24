#!/bin/sh

reads="$1"
read_type=$(basename ${reads})
read_type_short=`echo ${read_type%_reads}`
data=${reads}/..
if [[ -z "$(ls ${reads}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

toulligqc_results=${data}/results/${read_type_short}_toulligqc_analyses/
mkdir -p ${toulligqc_results}

for x in ${reads}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.fastq.gz}`
  if [ -f ${toulligqc_results}/${name}_toulligqc_report.html ]; then
    echo "Toulligqc has already analyzed ${name}"
  elif [ -f logs/${name}_toulligzc_hydra.log ]; then
    rm logs/${name}_toulligzc_hydra.log
    qsub -o logs/${name}_toulligqc_hydra.log \
    -N ${name}_toulligqc \
    toulligqc_loop.job ${reads} ${sample} ${name} ${toulligqc_results}
  else
    qsub -o logs/${name}_toulligqc_hydra.log \
    -N ${name}_toulligqc \
    toulligqc_loop.job ${reads} ${sample} ${name} ${toulligqc_results}
  fi
  sleep 0.1
done



# This script runs a toulligqc analysis on multiple fastq nanopore sequences, it can
# work with raw, trimmed, or trimmed and filtered sequences. 

# Raw sequences should be in PROJECT/data/raw/, trimmed sequences should be
# PROJECT/data/trimmed_reads/, and filtered sequences should be in PROJECT/data/filtered_reads/. 
# For each sample file, it will output html and log files into the folder 
# results/<read type>_toulligqc_analyses/ You can download this entire folder 
# to your local computer. Open this file with your
# browser and view the visual representations of your sample quality.

