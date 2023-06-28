#!/bin/sh

results="$1"
cd ${results}
mkdir ../spades_scaffolds
mkdir ../error_corrected_reads
for x in ${results}/*; do 
  sample=`basename ${x}`
  ls ${sample}/scaffolds.fasta &> /dev/null  || echo "Correct path to SPAdes results not entered"
  cp ${sample}/scaffolds.fasta ${results}/../spades_scaffolds/${sample}_spades_scaffolds.fasta
  cp ${sample}/spades.log ${results}/../spades_scaffolds/${sample}_spades.log
  cp ${sample}/corrected/* ${results}/../error_corrected_reads/
done
