#!/bin/sh

trimmed="$1"
data=${trimmed}/../
mkdir -p ${data}/results/spades

ls ${trimmed}/*.fastq.gz &> /dev/null  || echo "Correct path to read files not entered (*.fastq.gz)"

for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_R*}`
  echo $sample
  echo $name
  
    qsub -o ${data}/results/spades/${name}_spades.log \
    -N ${name}_spades \
    spades.job ${trimmed} ${name} ${data}
    
done
