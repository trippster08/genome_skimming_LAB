#!/bin/sh

assemblies="$1"
taxa="$2"
ref="$3"
results=${assemblies}/../

if [[ -z "$(ls ${assemblies}/*_medaka_consensus.fasta 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to corrected flye results not entered (*_medaka_consensus.fasta)"
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

mkdir -p ${results}/mitofinder_flye ${results}/mitofinder_results

for x in ${assemblies}/*_medaka_consensus.fasta ; do 
    sample=`basename ${x}`
    name=`echo ${sample%_medaka_consensus.fasta}`
    if [ -d ${results}/mitofinder_results/${name}_mitofinder_flye_Final_Results ]; then
      echo "MitoFinder has already annotated flye assemblies for ${name}"
    elif [ -f logs/${name}_mitofinder_flye_hydra.log ]; then
      if [ -d ${results}/mitofinder_flye/${name}_mitofinder_flye ]; then
        if [ -f ${results}/mitofinder_results/${name}_mitofinder_flye_hydra.log ]; then
          rm -r ${results}/mitofinder_flye/${name}_mitofinder_flye ${results}/mitofinder_results/${name}_mitofinder_flye_hydra.log \
          ${results}/mitofinder_flye/${name}_mitofinder_flye_MitoFinder.log logs/${name}_mitofinder_flye_hydra.log
          qsub -o ${results}/../../jobs/logs/${name}_mitofinder_flye_hydra.log \
          -wd ${results}/mitofinder_flye \
          -N ${name}_mitofinder_flye \
          mitofinder_annotate_flye_loop.job ${assemblies} ${name} ${taxa} ${ref} ${sample} ${results}
        else
          rm -r ${results}/mitofinder_flye/${name}_mitofinder_flye ${results}/mitofinder_flye/${name}_mitofinder_flye_MitoFinder.log \
          logs/${name}_mitofinder_flye_hydra.log
          qsub -o ${results}/../../jobs/logs/${name}_mitofinder_flye_hydra.log \
          -wd ${results}/mitofinder_flye \
          -N ${name}_mitofinder_flye \
          mitofinder_annotate_flye_loop.job ${assemblies} ${name} ${taxa} ${ref} ${sample} ${results}
        fi
      else
        rm logs/${name}_mitofinder_flye_hydra.log
        qsub -o ${results}/../../jobs/logs/${name}_mitofinder_flye_hydra.log \
        -wd ${results}/mitofinder_flye \
        -N ${name}_mitofinder_flye \
        mitofinder_annotate_flye_loop.job ${assemblies} ${name} ${taxa} ${ref} ${sample} ${results}
      fi
    else
      qsub -o ${results}/../../jobs/logs/${name}_mitofinder_flye_hydra.log \
      -wd ${results}/mitofinder_flye \
      -N ${name}_mitofinder_flye \
      mitofinder_annotate_flye_loop.job ${assemblies} ${name} ${taxa} ${ref} ${sample} ${results}
    fi
  sleep 0.1
done


# This is different from a normal mitofinder run because it doesn't use the raw
# sequences as an input, but instead uses the assemblies.fasta output from a
# flye assembly. This is signficantly faster, and I have found that flye 
# seems to be better at finding entire mitogenome assemblies than mitofinder.

# Mitofinder defaults to put the output in the same folder from which the 
# program was run, and there doesn't appear to be a way to change this. "-wd",
# tells hydra to run the program in whatever directory is listed, in this case 
# results/mitofinder_flye. Since this would also cause the log
# files to be placed here, I have also changed the log output "-o" to jobs/logs/

# This MitoFinder shell requires three elements after calling the script
# 1: path to the flye assemblies
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