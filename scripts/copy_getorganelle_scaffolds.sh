#!/bin/sh

results="$1"
cd ${results}

mkdir ../getorganelle_scaffolds

for x in ${results}/*/; do 
  sample=`basename ${x}`
  for y in ${results}/${sample}/*path_sequence.fasta; do
    sample2=`basename ${y}`
    name=`echo ${sample2%_path_sequence.fasta}`
  cp ${sample}/${sample2} ../getorganelle_scaffolds/${sample}_${sample2}
  cp ${sample}_getorganelle.log ../getorganelle_scaffolds/${sample}.log
  done
done

# This makes a new folder called "getorganelle_scaffolds", and copies all
# scaffolds from each getorganelle results folder. Since GetOrganelle names
# it's scaffolds generically, this script also renames them by adding the
# sample name to the beginning of each
