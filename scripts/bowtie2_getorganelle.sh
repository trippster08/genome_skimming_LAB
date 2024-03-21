#!/bin/sh

contigs="$1"
trimmed="$2"
results=${contigs}/../

if
  [[ -z "$(ls ${contigs}/*_sequence.fasta 2>/dev/null | grep fasta)" ]] 
then
  echo "Correct path to SPAdes results not entered (*_spades_contigs.fasta)"
  exit
fi

mkdir -p ${results}/bowtie2_getorganelle

for x in ${contigs}/*_path_sequence.fasta ; do 
    sample=`basename ${x}`
    name=`echo ${sample%.path_sequence.fasta}`
echo ${name}
echo ${sample}
    qsub -o ${results}/bowtie2_getorganelle/${name}_bowtie2_getorganelle.log \
    -wd ${results}/bowtie2_getorganelle \
    -N ${name}_bowtie2_getorganelle \
    bowtie2_getorganelle.job ${contigs} ${name} ${sample} ${trimmed} ${results}
done
