#!/bin/sh

raw="$1"
data=${raw}/../

if
  [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]  
then  
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${data}/trimmed_sequences

for x in ${raw}/*_R1* ; do 
  sample=`basename ${x}`
  name=`echo ${sample%%_*}`
  nameplus=`echo ${sample%_R*}`
  post=`echo ${sample#*_R[1-2]*}`
  # echo $sample
  # echo $name
  # echo $nameplus

  qsub -o logs/${name}_fastp.log \
  -N ${name}_fastp \
  fastp_loop.job ${raw} ${data} ${name} ${nameplus} ${post}

  sleep 0.1
done

# This script submits the jobs to run fastp to quality trim and remove adapters from raw reads. See .job file for parameter directions
