#!/bin/sh

reads="$1"
read_type=$(basename ${reads})
read_type_short=`echo ${read_type%_reads}`
data=${reads}/..
if [[ -z "$(ls ${reads}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi


mkdir -p ${data}/results/${read_type_short}_toulligqc_analyses
results=${data}/results/${read_type_short}_toulligqc_analyses
toulligqc_results=${results}/${read_type_short}_toulligqc_analyses

for x in ${reads}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.fastq.gz}`
  if [ -f ${toulligqc_results}/${name}_toulligqc_report.html ]; then
    echo "Toulligqc has already analyzed ${name}"
  elif [ -f logs/${name}_toulligzc_hydra.log ]; then
    rm logs/${name}_toulligzc_hydra.log
    qsub -o logs/${name}_toulligqc_hydra.log \
    -N ${name}_toulligqc \
    toulligqc_loop.job ${reads} ${sample} ${name} ${data} ${toulligqc_results}
  else
    qsub -o logs/${name}_toulligqc_hydra.log \
    -N ${name}_toulligqc \
    toulligqc_loop.job ${reads} ${sample} ${name} ${data} ${toulligqc_results}
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
