#!/bin/sh

path="$1"
reference="$2"
repath=`echo ${path} | cut -d "/" -f 1,2,3,4,5,6`


 for x in ${path}/*_R1_PE_trimmed.fastq.gz ; do 
    sample=`echo ${x} | cut -d "_" -f 1,2,3,4 | cut -d "/" -f 8`

    qsub -o logs/${sample}_mitofinder.log \
    -N ${sample}_mitofinder \
    mitofinder_multi.job ${path} ${sample} ${reference}

echo ${path}
echo ${sample}
done

