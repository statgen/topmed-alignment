#!/bin/sh

for bam in $*; do
  export DELAY=$(($RANDOM % 120))
  export BAM_FILE=$bam
  export SAMPLE_ID="$(samtools view -H $bam| grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2)"

  if [ $SAMPLE_ID -ne '63305' ]; then
    job_name=gecco-${SAMPLE_ID}
    echo "Submitting BAM: $BAM_FILE for alignment with SAMPLE_ID: $SAMPLE_ID with initial DELAY: $DELAY"
    sbatch -J "gecco-${SAMPLE_ID}" batch.d/gecco.sh
  fi
done
