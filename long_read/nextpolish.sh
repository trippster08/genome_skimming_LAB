#!/bin/sh

medaka_corrected_assemblies="$1"
trimmed_illumina_reads="$2"

results=${medaka_corrected_assemblies}/../results

if
  [[ -z "$(ls ${medaka_corrected_assemblies}/*_medaka_consensus.fasta 2>/dev/null | grep fasta)" ]]; then
  echo "Correct path to medaka-corrected contigs not entered (*_medaka_consensus.fasta)"
  exit
fi

if
  [[ -z "$(ls ${trimmed_illumina_reads}/*.fastq.gz 2>/dev/null | grep fastq.gz)" ]]; then
  echo "Correct path to trimmed illumina read files not entered (*trimmed.fastq.gz)"
  exit
fi

mkdir -p ${results}/nextpolish ${results}/nextpolished_assemblies

for x in ${trimmed_illumina_reads}/*R1_PE_trimmed.fastq.gz ; do
  sample=${x##*/}
  name=${sample%_R1_PE_trimmed.fastq.gz}
  # echo ${sample}
  # echo ${name}
  if [ -f ${results}/nextpolished_assemblies/${name}_genome_nextpolished.fasta ]; then
    echo "Assemblies for ${name} have already benn polished by nextPolish"
  else
    # Create .fofn file
    echo ${trimmed_illumina_reads}/${name}_R1_PE_trimmed.fastq.gz > ${results}/nextpolish/${name}.fofn
    echo ${trimmed_illumina_reads}/${name}_R2_PE_trimmed.fastq.gz >> ${results}/nextpolish/${name}.fofn
    # Create run.cfg file
    cat > "${results}/nextpolish/${name}_run.cfg" <<EOF
[General]
job_type = local
job_prefix = nextPolish
task = best
rewrite = yes
rerun = 3
parallel_jobs = 6
multithread_jobs = 5
genome = ${medaka_corrected_assemblies}/${name}_medaka_consensus.fasta #genome file
genome_size = auto
workdir = ${results}/nextpolish/${name}
polish_options = -p {multithread_jobs} -u -debug

[sgs_option]
sgs_fofn = ${results}/nextpolish/${name}.fofn
sgs_options = -max_depth 100 -bwa
EOF
    qsub -o logs/${name}_nextpolish_hydra.log \
    -N ${name}_nextpolish \
    nextpolish_loop.job ${name} ${results}
  fi
  sleep 0.1
done
