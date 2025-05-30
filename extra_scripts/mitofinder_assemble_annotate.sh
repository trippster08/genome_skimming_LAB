#!/bin/sh

trimmed="$1"
taxa="$2"
ref="$3"
data=${trimmed}/../

if [[ -z "$(ls ${trimmed}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to trimmed reads not entered (*.fastq.gz)"
  exit
fi

if [[ -z $2 ]]; then
  echo "Genetic code not entered (should be a number between 1 and 25)"
  exit
fi

if
  [[ ${ref} != Annelida && ${ref} != Arthropoda && ${ref} != Bryozoa && ${ref} != Cnidaria && ${ref} \
  != Ctenophora && ${ref} != Echinodermata && ${ref} != Mollusca && ${ref} != Nemertea && \
  ${ref} != Porifera && ${ref} != Tunicata && ${ref} != Vertebrata && ${ref} != Metazoa ]]; then
  echo 'Incorrect reference database. Please enter "Annelida", "Arthropoda", "Bryozoa", "Cnidaria", \
   "Ctenophora", "Echinodermata", "Mollusca", "Nemertea", "Porifera", "Tunicata", "Vertebrata" or , "Metazoa"'
  exit
fi

mkdir -p ${data}/results/mitofinder ${data}/results/mitofinder_results

for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_R1_*}`
  #echo ${name}
  
  qsub -o ${data}/../jobs/logs/${name}_mitofinder.log \
  -wd ${data}/results/mitofinder \
  -N ${name}_mitofinder \
  mitofinder_assemble_annotate_loop.job ${trimmed} ${name} ${taxa} ${ref} ${sample} ${data}

  sleep 0.1
done



# -1 is the path to the R1 PE trimmed file, -2 is the path to the R2 PE trimmed
#  file. PE files come in pairs, both the R1 and R2 are present. 
# -o is the genetic code to use. The list below is from the mitofinder
# documantation (https://github.com/RemiAllio/MitoFinder/blob/master/README.md).
# -r is the path to the reference database, in genbank (.gb) format. Mitofinder
# documentation (https://github.com/RemiAllio/MitoFinder/blob/master/README.md),
# shows how to create a reference database from NCBI.
# --new-genes denotes that some of the genes in the reference database are not
# one of the "official" genes as determined by mitofinder. This is often true
# if you have downloaded the reference database from genbank, because there are 
# some mispellings in gene names in genbank.

# Mitofinder defaults to put the output in the same folder from which the 
# program was run, and there doesn't appear to be a way to change this. "-wd",
# tells hydra to run the program in whatever directory is listed, in this case 
# results/mitofinder. Since this would also cause the log
# files to be placed here, I have also changed the log output "-o" to jobs/logs/

# This MitoFinder shell requires three elements after calling the script
# 1: path to the directory containing the trimmed reads
# 2: the genetic code (see below)
# 3: taxonomic group for reference database (see bottom)

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