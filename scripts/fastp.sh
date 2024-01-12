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

for x in ${raw}/*R1_001.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%%_*}`
  nameplus=`echo ${sample%_R*}`
  # echo $sample
  # echo $name
  # echo $nameplus

    qsub -o logs/${name}_fastp.log \
    -N ${name}_fastp \
    fastp.job ${raw} ${data} ${name} ${nameplus}
done

# This script quality trims and removes adapters from raw reads using the program fastp. See .job file for parameter directions
