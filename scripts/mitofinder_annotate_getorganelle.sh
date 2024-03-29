#!/bin/sh

contigs="$1"
taxa="$2"
ref="$3"
results=${contigs}/../

if
  [[ -z "$(ls ${contigs}/*_sequence.fasta 2>/dev/null | grep fasta)" ]] 
then
  echo "Correct path to SPAdes results not entered (*_spades_contigs.fasta)"
  exit
fi

if
  [[ -z $2 ]]
then
  echo "Genetic code not entered (should be a number between 1 and 25)"
  exit
fi

if
  [[ ${ref} != Mollusca && ${ref} != Cnidaria && ${ref} != Arthropoda && ${ref} \
  != Annelida && ${ref} != Vertebrata && ${ref} != Metazoa && \
  ${ref} != Tunicata && ${ref} != Echinodermata && ${ref} != Bryozoa ]]
then
  echo 'Incorrect reference database. Please enter "Annelida", "Arthropoda", "Bryozoa", "Cnidaria",' \
   '"Ctenophora", "Echinodermata", "Metazoa", "Mollusca", "Nemertea", "Porifera", "Tunicata", or "Vertebrata"'
  exit
fi

mkdir -p ${results}/mitofinder_getorganelle

for x in ${contigs}/*.path_sequence.fasta ; do 
    sample=`basename ${x}`
    name=`echo ${sample%.path_sequence.fasta}`
echo ${name}
    qsub -o ${results}/mitofinder_getorganelle/${name}_mitofinder_getorganelle.log \
    -wd ${results}/mitofinder_getorganelle \
    -N ${name}_mitofinder_getorganelle \
    mitofinder_annotate_getorganelle.job ${contigs} ${name} ${taxa} ${ref} ${sample}
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

# This MitoFinder shell requires three elements after calling the script
# 1: path to the spades contigs
# 2: the genetic code
# 3: taxonomic group for reference database

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

# Using a more limited reference database greatly reduces run time. For exmaple,
# changing from the full database (14000+ mitogenomes) to just molluscs (<500
# mitogenomes) reduces run time from > 3 hours to < 5 minutes, typically.
# Currently there are 11 taxon-specific databases: 
# "Annelida"
# "Arthropoda"
# "Bryozoa"
# "Cnidaria"
# "Ctenophora"
# "Echinodermata"
# "Mollusca"
# "Nemertea"
# "Porifera"
# "Tunicata"
# "Vertebrata"
# There is one database containing the full Genbank refseq database:
# "Metazoa"
# If your taxa of interest are not in one of these groups, you can either enter
# "Metazoa" to use the entire database or contact me and I can typically create
# your chosen database in short order.