#!/bin/sh

trimmed="$1"
results=${trimmed}/../results


if [[ -z "$(ls ${trimmed}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi

mkdir -p ${results}/spades ${results}/spades_contigs

for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do
  sample=`basename ${x}`
  name=`echo ${sample%_R[1-2]_*}`
#  echo $sample
#  echo $name
  if [ -f ${name}_spades_contigs.fasta ]; then
    echo "Sample ${name} already has SPAdes assemblies"
  elif [ -f logs/${name}_spades_hydra.log ]; then
    if [ -d ${results}/spades/${name} ]; then
      if [ -f ${results}/spades_contigs/${name}_spades_hydra.log ]; then
        rm -r ${results}/spades/${name} logs/${name}_spades_hydra.log ${results}/spades_contigs/${name}_spades_hydra.log   
        qsub -o logs/${name}_spades_hydra.log \
        -N ${name}_spades \
        spades_loop.job ${trimmed} ${name} ${results}
      else
        rm -r ${results}/spades/${name} logs/${name}_spades_hydra.log
        qsub -o logs/${name}_spades_hydra.log \
        -N ${name}_spades \
        spades_loop.job ${trimmed} ${name} ${results}
      fi
    else
      rm logs/${name}_spades_hydra.log
      qsub -o logs/${name}_spades_hydra.log \
      -N ${name}_spades \
      spades_loop.job ${trimmed} ${name} ${results}
    fi
  else
    qsub -o logs/${name}_spades_hydra.log \
    -N ${name}_spades \
    spades_loop.job ${trimmed} ${name} ${results}
  fi
  sleep 0.1
done

