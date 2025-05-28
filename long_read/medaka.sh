#!/bin/sh

assemblies="$1"
raw_nanopore="$2"
results=${assemblies}/../

if
  [[ -z "$(ls ${assemblies}/*_flye_assembly.fasta 2>/dev/null | grep fasta)" ]] 
then
  echo "Correct path to flye results not entered (*_flye_assembly.fasta)"
  exit
fi

if
  [[ -z "$(ls ${raw_nanopore}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to trimmed read files not entered (*trimmed.fastq.gz)"
  exit
fi

mkdir -p ${results}/medaka ${results}/medaka_corrected_assemblies


 for x in ${assemblies}/*flye_assembly.fasta ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_flye_assembly.fasta}`
  mkdir ${results}/medaka/${name}
  qsub -o logs/${name}_medaka_hydra.log \
  -N ${name}_medaka \
  medaka_loop.job ${assemblies} ${raw_nanopore} ${sample} ${name} ${results}

  sleep 0.1
done