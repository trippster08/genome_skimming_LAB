#!/bin/sh

results="$1"
cd ${results}

mkdir ../mitofinder_final_results

for x in ${results}/*/; do 
  sample=`basename ${x}`
  ls ${sample}/${sample}_Final_Results &> /dev/null  || echo "Correct path to MitoFinder results not entered"
  cp -r ${sample}/${sample}_Final_Results ../mitofinder_final_results/${sample}_final_results
  cp ${sample}_MitoFinder.log ../mitofinder_final_results/${sample}.log
done
