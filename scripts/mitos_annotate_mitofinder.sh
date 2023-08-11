#!/bin/sh

mitofinder_contigs="$1" 
taxa="$2"
results=${mitofinder_contigs}/../
mkdir -p ${results}/mitos_mitofinder

if [[ -z $2 ]];
  then
  echo "Genetic code not entered (should be a number between 1 and 25)"
fi

for x in ${mitofinder_contigs}/* ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_mitofinder_spades_contigs.fasta}`

  mkdir -p ${results}/mitos_mitofinder/${name}
  
  qsub -o ${results}/mitos_mitofinder/${name}_mitos_mitofinder.log \
  -N ${name}_mitos_mitofinder \
  mitos_annotate_mitofinder.job ${mitofinder_contigs} ${results} ${sample} ${name} ${taxa}
done

# This MITOS shell requires two elements after calling the script
# 1: path to the MitoFinder contigs
# 2: the taxonomic group
