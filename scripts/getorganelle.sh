#!/bin/sh

trimmed="$1"
organelle="$2"
data=${trimmed}/../

if
  [[ ${2} != animal_mt && ${2} != embplant_pt && ${2} != fungus_mt && ${2} != embplant_mt && ${2} \
  != embplant_nr && ${2} != other_pt ]]
then
  echo 'Correct organelle not entered. Please enter "animal_mt", "embplant_pt", "fungus_mt", "embplant_mt", \
   "embplant_nr", or "other_pt" after path to trimmed reads.'
  exit
fi

mkdir -p ${data}/results/getorganelle/ ${data}/results/getorganelle_contigs
echo "GetOrganelle was not able to find the correct complete mitogenome for these samples. \
Instead it found multiple similar contigs with different repetitive regions attached. These \
contigs will not be copied to getorganelle_contigs/" \
>  ${data}/results/getorganelle_contigs/getorganelle_repeats.txt
echo "GetOrganelle was not able to find complete mitogenomes for these samples, instead \
only finding smaller contig(s) that could not be joined. These contigs will be copied to \
getorganelle_cotigs/ as scaffolds." \
>  ${data}/results/getorganelle_contigs/getorganelle_scaffolds.txt
echo "GetOrganelle was not able to find any contigs for these samples. Please see each samples \
respective log file for further information." \
>  ${data}/results/getorganelle_contigs/getorganelle_failed.txt

 for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%%_*}`

  qsub -o logs/${name}_getorganelle.log \
  -N ${name}_getorganelle \
  getorganelle_loop.job ${trimmed} ${organelle} ${name} ${data}

  sleep 0.1
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