#!/bin/sh

path="$1"
repath=`echo ${path} | cut -d "/" -f 1,2,3,4,5,6`
mkdir -p ${repath}/results/spades

for x in ${path}/*_R1_PE_trimmed.fastq.gz ; do 
    sample=`echo ${x} | cut -d "_" -f 1,2,3,4 | cut -d "/" -f 8`
    
    qsub -o logs/${sample}_spades.log \
    -N ${sample}_spades \
    spades_multi.job ${path} ${sample} ${repath}
echo ${path}
echo ${sample}
echo ${repath}
done
