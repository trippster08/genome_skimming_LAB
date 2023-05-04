#!/bin/sh

trimmed="$1"
taxa="$2"
parent=${trimmed}/../../
mkdir -p ${parent}/data/results/mitofinder

ls ${trimmed}/*.fastq.gz &> /dev/null  || echo "Correct path to read files not entered (*.fastq.gz)"

if [[ -z $2 ]];
  then
  echo "Genetic code not entered (should be a number between 1 and 25)"
fi

for x in ${trimmed}/*_R1_PE_trimmed.fastq.gz ; do 
  sample=`basename ${x}`
  name=`echo ${sample%_R*}`

  qsub -o ${parent}/jobs/logs/${name}_mitofinder.log \
  -wd ${parent}/data/results/mitofinder \
  -N ${name}_mitofinder \
  mitofinder.job ${trimmed} ${name} ${taxa}
done

# Mitofinder defaults to put the output in the same folder from which the 
# program was run, and there doesn't appear to be a way to change this. So, I
# added "-wd", which tells hydra to run the program in whatever directory is
# listed, in this case mitofinder/results/. Since this would also cause the log
# files to be placed here, I have also changed the log output "-o" to jobs/logs/
