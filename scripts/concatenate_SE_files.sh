#!/bin/sh

dir="$1"

cd ${dir}

for x in *_R1_SE_trimmed.fastq.gz ; do 
  base=`echo ${x} | cut -d "_" -f 1,2`
  cat ${base}_R1_SE_trimmed.fastq.gz ${base}_R2_SE_trimmed.fastq.gz > ${base}_SE_concat.fastq.gz
done
