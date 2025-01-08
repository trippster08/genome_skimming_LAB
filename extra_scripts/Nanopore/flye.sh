#!/bin/sh

trimmed_nanopore="$1"
data=${trimmed_nanopore}/../

if
  [[ -z "$(ls ${trimmed_nanopore}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi


mkdir -p ${data}/results/flye ${data}/results/flye_assemblies 
results=${data}/results/

 for x in ${trimmed_nanopore}/*_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.trimmed_fastq.gz}`
  mkdir ${results}/flye/${name}
  qsub -o logs/${name}_flye_hydra.log \
  -N ${name}_flye \
  flye_loop.job ${trimmed_nanopore} ${sample} ${name} ${results}

  #sleep 0.1
done
