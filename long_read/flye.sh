#!/bin/sh

raw="$1"
data=${raw}/../

if
  [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi


mkdir -p ${data}/results/flye ${data}/results/flye_assemblies 
results=${data}/results/

 for x in ${raw}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.fastq.gz}`
  mkdir ${results}/flye/${name}
  qsub -o logs/${name}_flye_hydra.log \
  -N ${name}_flye \
  flye_loop.job ${raw} ${sample} ${name} ${results}

  #sleep 0.1
done
