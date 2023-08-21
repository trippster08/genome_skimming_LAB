#!/bin/sh

results="$1"
cd ${results}
mkdir ../spades_contigs
mkdir ../spades_error_corrected_reads
for x in ${results}/*; do 
  sample=`basename ${x}`
  ls ${sample}/contigs.fasta &> /dev/null  || echo "Correct path to SPAdes results not entered"
  cp ${sample}/contigs.fasta ${results}/../spades_contigs/${sample}_spades_contigs.fasta
  cp ${sample}_spades.log ${results}/../spades_contigs/${sample}_spades.log
  cp ${sample}/corrected/* ${results}/../spades_error_corrected_reads/
done
