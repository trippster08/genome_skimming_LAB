#!/bin/sh

contigs="$1"
raw_nanopore="$2"
results=${contigs}/../

if
  [[ -z "$(find ${contigs}/ -name '*.fasta' 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to mitofinder contig not entered (*_mtDNA_contig.fasta)"
  exit
fi

if
  [[ -z "$(ls ${raw_nanopore}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to raw nanopore read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${results}/minimap_results


for x in ${contigs}/*_mitofinder_flye_Final_Results/; do
  mitofinder_final_results=${x##*/}
  name=`echo ${mitofinder_final_results%_mitofinder_flye_Final_Results}`
  if [ -s ${results}/minimap_results/${name}_minimap_mitofinder.bam ]; then
    echo "Reads have already been mapped to mitofinder contigs for ${name}"
  elif [ -f ${results}minimap_results/${name}_minimap_hydra.log ]; then
    rm ${results}/minimap_results/${name}_minimap_hydra.log ${results}/minimap_results/${name}_minimap_mitofinder.bam\
    logs/${name}_minimap_hydra.log 
    qsub -o logs/${name}_minimap_hydra.log \
    -N ${name}_minimap \
    minimap_loop.job ${contigs} ${raw_nanopore} ${name} ${results}     
  elif [ -f logs/${name}_minimap_hydra.log ]; then
    rm logs/${name}_minimap_hydra.log
    qsub -o logs/${name}_minimap_hydra.log \
    -N ${name}_minimap \
    minimap_loop.job ${contigs} ${raw_nanopore} ${name} ${results}
  else
    qsub -o logs/${name}_minimap_hydra.log \
    -N ${name}_minimap \
    minimap_loop.job ${contigs} ${raw_nanopore} ${name} ${results}
  fi
  sleep 0.1
done