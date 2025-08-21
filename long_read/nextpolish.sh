#!/bin/sh

medaka_corrected_assemblies="$1"
trimmed_illumina_reads="$2"

results=${medaka_corrected_assemblies}/../results

if
  [[ -z "$(ls ${medaka_corrected_assemblies}/*_medaka_consensus.fasta 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to medaka-corrected contigs not entered (*_medaka_consensus.fasta)"
  exit
fi

if
  [[ -z "$(ls ${trimmed_illumina_reads}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to trimmed illumina read files not entered (*trimmed.fastq.gz)"
  exit
fi

mkdir -p ${results}/nextpolish ${results}/nextpolished_assemblies

for x in ${trimmed_illumina_reads}/*R1_PE_trimmed.fastq.gz ; do
  sample=${x##*/}
  name=${sample%_R1_PE_trimmed.fastq.gz}
  # echo ${sample}
  # echo ${name}
  mkdir -p ${results}/nextpolish/${name}
  if [ -f ${results}/nextpolished_assemblies/${name}_genome_nextpolished.fasta ]; then
    echo "Assemblies for ${name} have already benn polished by nextPolish"
  else
    qsub -o logs/${name}_nextpolish_hydra.log \
    -N ${name}_nextpolish \
    nextpolish_loop.job ${name} ${results} ${trimmed_illumina_reads} ${medaka_corrected_assemblies}
  fi
  sleep 0.1
done
