#!/bin/sh

assemblies="$1"
mito_code="$2"
ref_database="$3"
results=${assemblies}/../
path_to_ref="/scratch/nmnh_lab/macdonaldk/ref/"

avail_ref=()
for file in ${path_to_ref}/mito_reference_*.gb; do
  ref_file=${file##file/}
  taxon=$(echo ${ref_file} | sed -E 's/^mito_reference_([A-Za-z]+)_[0-9]{2}[A-Za-z]{3}[0-9]{2}\.gb$/\1/')
  avail_ref+=(${taxon})
done

if [[ -z "$(ls ${assemblies}/*_medaka_consensus.fasta 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to the medaka-corrected flye results not entered (*_medaka_consensus.fasta)"
  exit
fi

if (( $2 < 1 || $2 > 25 )); then
  echo "Genetic code must be a number between 1 and 25"
  exit 1
fi

# Check if the argument is in the list of valid names
if [[ ! " ${avail_ref[@]} " =~ " ${ref_database} " ]]; then
  echo "Incorrect reference database. Available options are:"
  printf ' - %s\n' "${avail_ref[@]}"
  exit 1
fi

mkdir -p ${results}/mitofinder_medaka ${results}/mitofinder_results

for x in ${assemblies}/*_medaka_consensus.fasta ; do 
    sample=${x##*/}
    name=${sample%_medaka_consensus.fasta}
    if [ -d ${results}/mitofinder_results/${name}_mitofinder_medaka_Final_Results ]; then
      echo "MitoFinder has already annotated medaka assemblies for ${name}"
    elif [ -f logs/${name}_mitofinder_medaka_hydra.log ]; then
      if [ -d ${results}/mitofinder_medaka/${name}_mitofinder_medaka ]; then
        if [ -f ${results}/mitofinder_results/${name}_mitofinder_medaka_hydra.log ]; then
          rm -r ${results}/mitofinder_medaka/${name}_mitofinder_medaka ${results}/mitofinder_results/${name}_mitofinder_medaka_hydra.log \
          ${results}/mitofinder_medaka/${name}_mitofinder_medaka_MitoFinder.log logs/${name}_mitofinder_medaka_hydra.log
          qsub -o ${results}/../../jobs/logs/${name}_mitofinder_medaka_hydra.log \
          -wd ${results}/mitofinder_medaka \
          -N ${name}_mitofinder_medaka \
          mitofinder_annotate_medaka_loop.job ${assemblies} ${name} ${mito_code} ${ref_database} ${sample} ${results} ${path_to_ref}
        else
          rm -r ${results}/mitofinder_medaka/${name}_mitofinder_medaka ${results}/mitofinder_medaka/${name}_mitofinder_medaka_MitoFinder.log \
          logs/${name}_mitofinder_medaka_hydra.log
          qsub -o ${results}/../../jobs/logs/${name}_mitofinder_medaka_hydra.log \
          -wd ${results}/mitofinder_medaka \
          -N ${name}_mitofinder_medaka \
          mitofinder_annotate_medaka_loop.job ${assemblies} ${name} ${mito_code} ${ref_database} ${sample} ${results} ${path_to_ref}
        fi
      else
        rm logs/${name}_mitofinder_medaka_hydra.log
        qsub -o ${results}/../../jobs/logs/${name}_mitofinder_medaka_hydra.log \
        -wd ${results}/mitofinder_medaka \
        -N ${name}_mitofinder_medaka \
        mitofinder_annotate_medaka_loop.job ${assemblies} ${name} ${mito_code} ${ref_database} ${sample} ${results} ${path_to_ref}
      fi
    else
      qsub -o ${results}/../../jobs/logs/${name}_mitofinder_medaka_hydra.log \
      -wd ${results}/mitofinder_medaka \
      -N ${name}_mitofinder_medaka \
      mitofinder_annotate_medaka_loop.job ${assemblies} ${name} ${mito_code} ${ref_database} ${sample} ${results} ${path_to_ref}
    fi
  sleep 0.1
done


# This is different from a normal mitofinder run because it doesn't use the raw
# sequences as an input, but instead uses the medaka_consensus.fasta output from a
# medaka-corrected flye assembly. 

# Mitofinder defaults to put the output in the same folder from which the 
# program was run, and there doesn't appear to be a way to change this. "-wd",
# tells hydra to run the program in whatever directory is listed, in this case 
# results/mitofinder_medaka. Since this would also cause the log
# files to be placed here, I have also changed the log output "-o" to jobs/logs/

# This MitoFinder shell requires three elements after calling the script
# 1: path to the medaka-corrected flye assemblies
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