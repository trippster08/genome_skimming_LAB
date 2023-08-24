#!/bin/sh

raw="$1"
data=${raw}/../

if
  ls ${raw}/*.fastq.gz &> /dev/null  
then  
  echo "Correct path to read files not entered (*.fastq.gz)";
  exit 1;
fi

mkdir -p ${data}/trimmed_sequences

for x in ${raw}/*R1_001.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_L0*}`
  nameplus=`echo ${sample%_R*}`
  # echo $sample
  # echo $name
  # echo $nameplus

    qsub -o logs/${name}_fastp.log \
    -N ${name}_fastp \
    fastp.job ${raw} ${data} ${name} ${nameplus}
done

# This script quality trims and removes adapters from raw reads using the program fastp. See .job file for parameter directions
