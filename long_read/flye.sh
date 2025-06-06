#!/bin/sh

raw="$1"
data=${raw}/../

if [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi


mkdir -p ${data}/results/flye ${data}/results/flye_assemblies 
results=${data}/results/

for x in ${raw}/*.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%.fastq.gz}`
  if [ -f ${results}/flye_assemblies/${name}_flye.log ]; then
    echo "Flye assemblies for ${name} have already been completed"
  elif [ -f logs/${name}_flye_hydra.log ]; then
    if [ -d ${results}/flye/${name} ]; then
      if [ -f ${results}/flye_assemblies/${name}_flye_hydra.log ]; then
        rm -r ${results}/flye/${name} ${results}/flye_assemblies/${name}_flye_hydra.log logs/${name}_flye_hydra.log
        mkdir ${results}/flye/${name}
        qsub -o logs/${name}_flye_hydra.log \
        -N ${name}_flye \
        flye_loop.job ${raw} ${sample} ${name} ${results}
      else
        rm -r ${results}/flye/${name} logs/${name}_flye_hydra.log
        mkdir ${results}/flye/${name}
        qsub -o logs/${name}_flye_hydra.log \
        -N ${name}_flye \
        flye_loop.job ${raw} ${sample} ${name} ${results}
      fi          
    else
      rm logs/${name}_flye_hydra.log
      mkdir ${results}/flye/${name}
      qsub -o logs/${name}_flye_hydra.log \
      -N ${name}_flye \
      flye_loop.job ${raw} ${sample} ${name} ${results}
    fi
  else
    mkdir ${results}/flye/${name}
    qsub -o logs/${name}_flye_hydra.log \
    -N ${name}_flye \
    flye_loop.job ${raw} ${sample} ${name} ${results}
  fi
  #sleep 0.1
done
