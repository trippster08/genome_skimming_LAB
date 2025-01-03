#!/bin/sh

trimmed_illumina="$1"
trimmed_nanopore="$2"
results=${trimmed_illumina}/../results


if
  [[ -z "$(ls ${trimmed_nanopore}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to trimmed nanopore files not entered (*.fastq.gz)"
  exit
fi

if
  [[ -z "$(ls ${trimmed_illumina}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to trimmed illumina files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${results}/spades_hybrid ${results}/spades_contigs

for x in ${trimmed_illumina}/*_R1_PE_trimmed.fastq.gz ; do
  sample=`basename ${x}`
  name=`echo ${sample%%_*}`
#  echo $sample
#  echo $name

    qsub -o logs/${name}_spades_hybrid_hydra.log \
    -N ${name}_spades_hybrid \
    spades_hybrid_loop.job ${trimmed_illumina} ${trimmed_nanopore} ${name} ${results}

  sleep 0.1
done
