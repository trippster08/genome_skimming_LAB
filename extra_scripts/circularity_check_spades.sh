#!/bin/sh

contigs="$1"
results=${contigs}/../

if [[ -z "$(ls ${contigs}/*_spades_contigs.fasta 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to SPAdes results not entered (*_spades_contigs.fasta)"
  exit
fi

mkdir -p ${results}/possible_mitogenomes

for x in ${contigs}/*_spades_contigs.fasta ; do 
    sample=`basename ${x}`
    name=`echo ${sample%_spades_contigs.fasta}`
    qsub -o ${results}/../../jobs/logs/${name}_mitofinder_spades.log \
    -wd ${results}/mitofinder_spades \
    -N ${name}_mitofinder_spades \
    mitofinder_annotate_spades_loop.job ${contigs} ${name} ${sample} ${results}

  sleep 0.1
done


