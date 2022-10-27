#!/bin/sh

path="$1"
data=`echo ${path} | cut -d "/" -f 1,2,3,4,5,6`

 for x in ${path}/*R1_001.fastq.gz ; do 
  sample=`echo ${x} | cut -d "_" -f 1,2,3 | cut -d "/" -f 8`
   
    qsub -o logs/${sample}_trimmomatic.log \
    -N ${sample}_trimmomatic \
    trimmomatic_multi.job ${path} ${sample} ${data}
echo ${path}
echo ${sample}
done
