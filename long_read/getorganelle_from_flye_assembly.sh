#!/bin/sh

assembly="$1"
organelle="$2"
data=${assembly}/../../

if
  [[ -z "$(ls ${assembly}/*_assembly_graph.gfa 2>/dev/null | grep graph.gfa)" ]]
then
  echo "Correct path to flye assembly graph not entered (*_assembly_graph.gfa)"
  exit
fi


if
  [[ ${2} != animal_mt && ${2} != embplant_pt && ${2} != fungus_mt && ${2} != embplant_mt && ${2} \
  != embplant_nr && ${2} != other_pt ]]
then
  echo 'Correct organelle not entered. Please enter "animal_mt", "embplant_pt", "fungus_mt", "embplant_mt", \
   "embplant_nr", or "other_pt" after path to SPAdes results.'
  exit
fi

mkdir -p ${data}/results/getorganelle_from_flye_assembly/ ${data}/results/getorganelle_contigs

 for x in ${assembly}/*_assembly_graph.gfa ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_flye_assembly_graph.gfa}`

  qsub -o logs/${name}_getorganelle_from_flye_assembly_hydra.log \
  -N ${name}_getorganelle_from_flye_assembly \
  getorganelle_from_flye_assembly_loop.job ${assembly} ${organelle} ${name} ${data}

  sleep 0.1
done

# This shell script submits a getorganelle job for each sample in the target
# (typically data/trimmed_sequences/) directory

# The GetOrganelle shell requires two elements after calling the script
# 1: path to the directory containing the trimmed sequences
# 2: the organelle you are trying to find. 
# Organelle list to use for the 2nd element passed in calling the shell script:
#   embplant_pt
#   other_pt
#   embplant_mt
#   embplant_nr
#   animal_mt
#   fungus_mt