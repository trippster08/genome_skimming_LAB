#!/bin/sh

contigs="$1"
filtered_nanopore="$2"
results=${contigs}/../

if
  [[ -z "$(find ${contigs}/ -name '*.fasta' 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to mitofinder contig not entered (*_contig.fasta)"
  exit
fi

if
  [[ -z "$(ls ${filtered_nanopore}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to filtered nanopore read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${results}/minimap_results


for x in ${contigs}/*_mitofinder_medaka_Final_Results; do
  mitofinder_final_results=${x##*/}
  name=`echo ${mitofinder_final_results%_mitofinder_medaka_Final_Results}`
  if [ -s ${results}/minimap_results/${name}_minimap_mitofinder_medaka.bam ]; then
    echo "Reads have already been mapped to mitofinder contigs for ${name}"
  elif [ -f ${results}minimap_results/${name}_minimap_medaka_hydra.log ]; then
    rm ${results}/minimap_results/${name}_minimap_medaka_hydra.log ${results}/minimap_results/${name}_minimap_mitofinder_medaka.bam\
    logs/${name}_minimap_medaka_hydra.log 
    qsub -o logs/${name}_minimap_medaka_hydra.log \
    -N ${name}_minimap_medaka \
    minimap_medaka_loop.job ${contigs} ${filtered_nanopore} ${name} ${results}     
  elif [ -f logs/${name}_minimap_medaka_hydra.log ]; then
    rm logs/${name}_minimap_medaka_hydra.log
    qsub -o logs/${name}_minimap_medaka_hydra.log \
    -N ${name}_minimap_medaka \
    minimap_medaka_loop.job ${contigs} ${filtered_nanopore} ${name} ${results}
  else
    qsub -o logs/${name}_minimap_medaka_hydra.log \
    -N ${name}_minimap_medaka \
    minimap_medaka_loop.job ${contigs} ${filtered_nanopore} ${name} ${results}
  fi
  sleep 0.1
done