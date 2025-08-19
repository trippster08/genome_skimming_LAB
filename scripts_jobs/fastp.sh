#!/bin/sh

raw="$1"
data=${raw}/../

if [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then  
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${data}/trimmed_reads

for x in ${raw}/*_R1* ; do 
  sample=${x##*/}
  name=$(echo ${sample} | awk -F'_S[0-9]{1,3}_' '{print $1}') 
  nameplus=`echo ${sample%_R*}`
  post=`echo ${sample#*_R[1-2]*}`
  # echo $sample
  # echo $name
  # echo $nameplus


  if [ -f ${data}/trimmed_reads/${name}_R1_PE_trimmed.fastq.gz ]; then
    echo "Reads for ${name} have already been trimmed by fastp"
  elif [ -f logs/${name}_fastp.log ]; then
    rm logs/${name}_fastp.log logs/${name}_fastp.json logs/${name}_fastp.html
    qsub -o logs/${name}_fastp.log \
    -N ${name}_fastp \
    fastp_loop.job ${raw} ${data} ${name} ${nameplus} ${post}
  else
    qsub -o logs/${name}_fastp.log \
    -N ${name}_fastp \
    fastp_loop.job ${raw} ${data} ${name} ${nameplus} ${post}
  fi
  sleep 0.1
done

# This script submits the jobs to run fastp to quality trim and remove adapters from raw reads. See .job file for parameter directions. It requires a single element after calling the script: the path to the directory containing the untrimmed (raw) reads
