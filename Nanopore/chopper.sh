#!/bin/sh

trimmed="$1"
data=${trimmed}/../

if
  [[ -z "$(ls ${trimmed}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then  
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${data}/filtered_reads

for x in ${trimmed}/*.fastq.gz ; do 
  sample=${x##*/}
  name=`echo ${sample%%_trimmed.fastq.gz}`

  # echo $sample
  # echo $name

  qsub -o logs/${name}_chopper_hydra.log \
  -N ${name}_chopper \
  chopper_loop.job ${trimmed} ${sample} ${name} ${data}

  sleep 0.1
done

# This script submits the jobs to run chopper to quality trim and remove adapters
# from trimmed reads. See .job file for parameter directions. It requires a single
# element after calling the script: the path to the directory containing the
# untrimmed (trimmed) reads