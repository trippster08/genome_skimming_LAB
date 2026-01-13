#!/bin/sh

sra="$1"
data=${sra}/../


for x in ${sra}/*/ ; do 
  sample=`basename ${x}`

if [[ -z "$(ls ${sra}/${sample}/*.sra 2>/dev/null | grep sra)" ]]; then  
  echo "Correct path to sra file not entered (*.sra)"
  exit
fi

    qsub -o logs/${sample}_fasterq-dump.log \
    -N ${sample}_fasterq-dump \
    convert_sra_loop.job ${sra} ${data} ${sample}
  sleep 0.1
done


