#!/bin/sh

trimmed="$1"
data=${trimmed}/../

if
  [[ -z "$(ls ${trimmed}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]  
then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${data}/results/spades

for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_R*}`
#  echo $sample
#  echo $name
  
    qsub -o ${data}/results/spades/${name}_spades.log \
    -N ${name}_spades \
    spades.job ${trimmed} ${name} ${data}
    
done
