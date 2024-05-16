#!/bin/sh

trimmed="$1"
data=${trimmed}/../


if
  [[ -z "$(ls ${trimmed}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]  
then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${data}/results/spades ${data}/results/spades_contigs
echo "SPAdes did not sucessfully assemble the following samples. Please check the  \
log to evaluate any problems. If you cannot get SPAdes to work on these samples, \
please see LAB staff."

results=${data}/${results}

for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_R*}`
#  echo $sample
#  echo $name
  
    qsub -o logs/${name}_spades.log \
    -N ${name}_spades \
    spades_loop.job ${trimmed} ${name} ${data} ${results}
    
done
