#!/bin/sh

results="$1"
cd ${results}

mkdir ../getorganelle_scaffolds

for x in ${results}/*/; do 
  sample=`basename ${x}`
  for y in ${results}/${sample}/*_sequence.fasta; do
    sample2=`basename ${y}`
    name=`echo ${sample2%_sequence*}`
    echo $sample
    echo $sample2
    echo $name
  cp ${sample}/${sample2} ../getorganelle_scaffolds/${sample}_${sample2}_sequence.fasta
  cp ${sample}_getorganelle.log ../getorganelle_scaffolds/${sample}.log
  done
done

