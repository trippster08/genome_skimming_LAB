#!/bin/sh

contigs="$1" 
taxa="$2"

if [[ -z $2 ]]; then
  echo "Genetic code not entered (should be a number between 1 and 25)"
  exit
fi

results=${contigs}/../
mkdir ${results}/mitos_results

echo "MITOS was not able to annotate the samples listed below. The most common problem \
is insufficient requested RAM. Please check run details for failed runs to see if \
maxvmem is greater than mem_res. If you have determined insufficient RAM was not \
the problem, see LAB staff for help troubleshooting" > \
${results}/mitos_results/mitos_failures.txt

for x in ${contigs}/*.path_sequence.fasta; do
  sample=`basename ${x}`
  name=`echo ${sample%.path_sequence.fasta}`
  shortname=`echo ${sample%%_animal_mt*}`

  mkdir -p ${results}/mitos_getorganelle/${shortname}_mitos_getorganelle
  mkdir -p ${results}/mitos_results/${shortname}_mitos_getorganelle
  
  qsub -o logs/${shortname}_mitos_getorganelle_hydra.log \
  -N ${shortname}_mitos_getorganelle \
  mitos_annotate_getorganelle_loop.job ${contigs} ${results} ${sample} ${name} ${taxa} ${shortname}

  sleep 0.1
done

# This script uses the contigs from a GetOrganelle output contig as a template
# for annotation, and submits a MITOS job for each contig in the source
# directory (typically results/getorganelle_contigs/).


# This MITOS shell requires two elements after calling the script
# 1: path to the directory containing the GetOrganelle contigs
# 2: the genetic code

# The shell expects one of the following Genetic codes
# 1. The Standard Code 
# 2. The Vertebrate Mitochondrial Code 
# 3. The Yeast Mitochondrial Code 
# 4. The Mold, Protozoan, and Coelenterate Mitochondrial Code and the
#     Mycoplasma/Spiroplasma Code
# 5. The Invertebrate Mitochondrial Code
# 6. The Ciliate, Dasycladacean and Hexamita Nuclear Code 
# 9. The Echinoderm and Flatworm Mitochondrial Code 
# 10. The Euplotid Nuclear Code 
# 11. The Bacterial, Archaeal and Plant Plastid Code 
# 12. The Alternative Yeast Nuclear Code 
# 13. The Ascidian Mitochondrial Code 
# 14. The Alternative Flatworm Mitochondrial Code 
# 16. Chlorophycean Mitochondrial Code 
# 21. Trematode Mitochondrial Code 
# 22. Scenedesmus obliquus Mitochondrial Code 
# 23. Thraustochytrium Mitochondrial Code 
# 24. Pterobranchia Mitochondrial Code 
# 25. Candidate Division SR1 and Gracilibacteria Code
