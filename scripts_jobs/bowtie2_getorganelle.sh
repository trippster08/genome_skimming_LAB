#!/bin/sh

contigs="$1"
trimmed="$2"
results=${contigs}/../

if [[ -z "$(ls ${contigs}/*.path_sequence.fasta 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to GetOrganelle results not entered (*.path_sequence.fasta)"
  exit
fi

if [[ -z "$(ls ${trimmed}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to trimmed read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${results}/bowtie2_getorganelle
mkdir -p ${results}/bowtie2_getorganelle_results

for x in ${contigs}/*.path_sequence.fasta ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.path_sequence.fasta}`
  shortname=${name%%_animal_mt*}
  if [ -f ${results}/bowtie2_getorganelle_results/${shortname}_bowtie_getorganelle.bam ]; then
    echo "Reads for ${shortname} have already been mapped to GetOrganelle contigs"
  elif [ -d ${results}/bowtie2_getorganelle/${shortname} ]; then
    if [ -f ${results}/../../jobs/logs/${shortname}_bowtie2_getorganelle_hydra.log ]; then
      rm -r ${results}/bowtie2_getorganelle/${shortname} ${results}/../../jobs/logs/${shortname}_bowtie2_getorganelle_hydra.log
      mkdir ${results}/bowtie2_getorganelle/${shortname}
      qsub -o ${results}/../../jobs/logs/${shortname}_bowtie2_getorganelle_hydra.log \
      -wd ${results}/bowtie2_getorganelle \
      -N ${shortname}_bowtie2_getorganelle \
      bowtie2_getorganelle_loop.job ${contigs} ${sample} ${trimmed} ${results} ${shortname}
    else
      rm -r ${results}/bowtie2_getorganelle/${shortname}
      mkdir ${results}/bowtie2_getorganelle/${shortname}
      qsub -o ${results}/../../jobs/logs/${shortname}_bowtie2_getorganelle_hydra.log \
      -wd ${results}/bowtie2_getorganelle \
      -N ${shortname}_bowtie2_getorganelle \
      bowtie2_getorganelle_loop.job ${contigs} ${sample} ${trimmed} ${results} ${shortname}
    fi
  else
    mkdir ${results}/bowtie2_getorganelle/${shortname}
    qsub -o ${results}/../../jobs/logs/${shortname}_bowtie2_getorganelle_hydra.log \
    -wd ${results}/bowtie2_getorganelle \
    -N ${shortname}_bowtie2_getorganelle \
    bowtie2_getorganelle_loop.job ${contigs} ${sample} ${trimmed} ${results} ${shortname}
  fi
  sleep 0.1
done

# This script submits a bowtie2 job to assemble all trimmed-reads from a sample
# onto all getorganelle contigs for that same sample. 

# The script requires two elements after calling the script: 
# 1 the path to the directory containing the getorganelle contigs
# 2 the path to the directory containing the trimmed sequences