#!/bin/sh

mitofinder_final_results="$1" 
taxa="$2"

if
  [[ -z $2 ]]
then
  echo "Genetic code not entered (should be a number between 1 and 25)"
  exit
fi

results=${mitofinder_final_results}/../

mkdir -p ${results}/mitofinder_contigs

for x in ${mitofinder_final_results}/*/; do
  sample=`basename ${x}`
  name=`echo ${sample%_mitofinder_final_results}`

[ ! -f ${mitofinder_final_results}/${sample}/${name}*contig.fasta ] || \
    cp ${mitofinder_final_results}/${sample}/${name}*contig.fasta \
    ${results}/mitofinder_contigs/${name}_mitofinder_mtDNA_contig.fasta 

[ ! -f ${mitofinder_final_results}/${sample}/${name}*[0-9].fasta ] 2>/dev/null || \
cat ${mitofinder_final_results}/${sample}/${name}*[0-9].fasta > \
        ${results}/mitofinder_contigs/${name}_mitofinder_mtDNA_contig.fasta 2>/dev/null


  mkdir -p ${results}/mitos_mitofinder/${name}_mitos_mitofinder

  qsub -o ${results}/mitos_mitofinder/${name}_mitos_mitofinder.log \
  -N ${name}_mitos_mitofinder \
  mitos_annotate_mitofinder.job ${mitofinder_final_results} ${results} ${sample} ${name} ${taxa}
done

# This MITOS shell requires two elements after calling the script
# 1: path to the directory containing the sample-specific MitoFinder final
# results directories
# 2: the genetic code

# The shell expects on of the following Genetic codes
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
