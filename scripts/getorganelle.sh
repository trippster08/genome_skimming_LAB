#!/bin/sh

trimmed="$1"
organelle="$2"
data=${trimmed}/../

mkdir -p ${data}/results/getorganelle/

 for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_R*}`

    qsub -o logs/${name}_getorganelle.log \
    -N ${name}_getorganelle \
    getorganelle.job ${trimmed} ${organelle} ${name} ${data}

done

# This GetOrganelle shell requires two elements after calling the script
# 1: path to the trimmed sequences
# 2: the organelle you are trying to find. 
# Organelle list to use for the 2nd element passed in calling the shell script:
#   embplant_pt
#   other_pt
#   embplant_mt
#   embplant_nr
#   animal_mt
#   fungus_mt