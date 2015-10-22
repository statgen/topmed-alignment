#!/bin/sh

for bam in $*; do
  export DELAY=$(($RANDOM % 120))
  export BAM_FILE=$bam
  export SAMPLE_ID="$(samtools view -H $bam| grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2)"

  job_name="inpsyght-${SAMPLE_ID}"

  echo "Submitting BAM: $BAM_FILE for alignment with SAMPLE_ID: $SAMPLE_ID with initial DELAY: $DELAY"
  # qsub -N $job_name batch.d/inpsyght.sh
  # sbatch -J $job_name batch.d/inpsyght.sh
done
