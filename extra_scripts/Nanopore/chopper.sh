#!/bin/sh

raw="$1"
data=${raw}/../

if
  [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]  
then  
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${data}/trimmed_reads_nanopore

for x in ${raw}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%%.fastq.gz}`

  # echo $sample
  # echo $name

  qsub -o logs/${name}_chopper.log \
  -N ${name}_chopper \
  chopper_loop.job ${raw} ${data} ${name}

  sleep 0.1
done

# This script submits the jobs to run chopper to quality trim and remove adapters
# from raw reads. See .job file for parameter directions. It requires a single
# element after calling the script: the path to the directory containing the
# untrimmed (raw) reads