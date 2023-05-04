#!/bin/sh

scaffolds="$1"
taxa="$2"
parent=${scaffolds}/../../../
mkdir -p ${parent}/data/results/mitofinder_spades

ls ${scaffolds}/*_spades_scaffolds.fasta &> /dev/null  || echo "Correct path to SPAdes results not entered (*_spades_scaffolds.fasta)"

if [[ -z $2 ]];
  then
  echo "Genetic code not entered (should be a number between 1 and 25)"
fi

for x in ${scaffolds}/*_spades_scaffolds.fasta ; do 
    sample=`basename ${x}`
    name=`echo ${sample%_spades_scaffolds.fasta}`

    qsub -o ${parent}/jobs/logs/${name}_mitofinder_spades.log \
    -wd ${parent}/data/results/mitofinder_spades \
    -N ${name}_mitofinder_spades \
    mitofinder_annotate_spades.job ${scaffolds} ${name} ${taxa}
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
