#!/bin/sh

path="$1"
repath=`echo ${path} | cut -d "/" -f 1,2,3,4,5,6`
mkdir -p ${repath}/results/getorganelle/

 for x in ${path}/*_R1_PE_trimmed.fastq.gz ; do 
    sample=`echo ${x} | cut -d "_" -f 1,2,3,4 | cut -d "/" -f 8`

    qsub -o logs/${sample}_getorganelle.log \
    -N ${sample}_getorganelle \
    getorganelle_multi.job ${path} ${sample} ${repath}

echo ${path}
echo ${sample}
echo ${repath}
done
