#!/bin/sh

contigs="$1"
taxa="$2"
results=${contigs}/../
mkdir -p ${results}/mitofinder

ls ${contigs}/*_spades_contigs.fasta &> /dev/null  || echo "Correct path to SPAdes results not entered (*_spades_contigs.fasta)"

if [[ -z $2 ]];
  then
  echo "Genetic code not entered (should be a number between 1 and 25)"
fi

for x in ${contigs}/*_spades_contigs.fasta ; do 
    sample=`basename ${x}`
    name=`echo ${sample%_spades_contigs.fasta}`

    qsub -o ${results}/mitofinder/${name}_mitofinder.log \
    -wd ${results}/mitofinder \
    -N ${name}_mitofinder \
    mitofinder_annotate_spades.job ${contigs} ${name} ${taxa}
done


# This is different from a normal mitofinder run because it doesn't use the raw
# sequences as an input, but instead uses the contigs.fasta output from a
# spades assembly. This is signficantly faster, and I have found that spades 
# seems to be better at finding entire mitogenome contigs than mitofinder.

# Mitofinder defaults to put the output in the same folder from which the 
# program was run, and there doesn't appear to be a way to change this. "-wd",
# tells hydra to run the program in whatever directory is listed, in this case 
# results/mitofinder_spades. Since this would also cause the log
# files to be placed here, I have also changed the log output "-o" to jobs/logs/

# This MitoFinder shell requires two elements after calling the script
# 1: path to the spades contigs
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