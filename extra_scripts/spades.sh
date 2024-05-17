#!/bin/sh

trimmed="$1"
results=${trimmed}/../results


if
  [[ -z "$(ls ${trimmed}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]
then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${results}/spades ${results}/spades_contigs

for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do
  sample=`basename ${x}`
  name=`echo ${sample%%_*}`
#  echo $sample
#  echo $name

    qsub -o logs/${name}_spades.log \
    -N ${name}_spades \
    spades_loop.job ${trimmed} ${name} ${results}

done
