#!/bin/sh

mitofinder_results="$1"

cd ${mitofinder_results}
mkdir ../mitofinder_final_results

for x in ${mitofinder_results}/*/; do 
  sample=`basename ${x}`

  if
    [[ -z "$(ls ${mitofinder_results}/${sample}/* 2>/dev/null | grep Final_Results)" ]] 
  then
    echo "Correct path to MitoFinder results not entered (*_contigs.fasta)"
    exit
  fi

  cp -r ${sample}/${sample}_Final_Results ../mitofinder_final_results/${sample}_final_results
  cp ${sample}.log ../mitofinder_final_results/${sample}.log
done
