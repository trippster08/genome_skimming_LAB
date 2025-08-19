 #!/bin/sh

raw="$1"
data=${raw}/../

if [[ -z "$(ls ${raw}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to read files not entered (*.fastq.gz)"
  exit
fi


mkdir -p ${data}/trimmed_reads/ 

for x in ${raw}/*.fastq.gz ; do 
  sample=${x##*/}
  name=`echo ${sample%.fastq.gz}`
  if [ -f ${trimmed_reads}/${name}_trimmed.fastq.gz ]; then
    echo "Primer/adapter trimming for ${name} has already been completed"
  elif [ -f logs/${name}_dorado_hydra.log ]; then
    rm -r logs/${name}_dorado_hydra.log
    qsub -o logs/${name}_dorado_hydra.log \
    -N ${name}_dorado \
    dorado_loop.job ${raw} ${sample} ${name} ${data}
  else
    qsub -o logs/${name}_dorado_hydra.log \
    -N ${name}_dorado \
    dorado_loop.job ${raw} ${sample} ${name} ${data}
  fi
  sleep 0.1
done
