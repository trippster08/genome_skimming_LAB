#!/bin/sh

spades_results="$1"

cd ${spades_results}
mkdir ../spades_contigs
mkdir ../spades_error_corrected_reads
for x in ${spades_results}/*/; do 
  sample=`basename ${x}`

  if
    [[ -z "$(ls ${spades_results}/${sample}/* 2>/dev/null | grep contigs.fasta)" ]] 
  then
    echo "Correct path to SPAdes results not entered (contigs.fasta)"
    exit
  fi  

  ls ${sample}/contigs.fasta &> /dev/null  || echo "Correct path to SPAdes results not entered"
  cp ${sample}/contigs.fasta ${spades_results}/../spades_contigs/${sample}_spades_contigs.fasta
  cp ${sample}_spades.log ${spades_results}/../spades_contigs/${sample}_spades.log
  cp ${sample}/corrected/${sample}* ${spades_results}/../spades_error_corrected_reads/
done
