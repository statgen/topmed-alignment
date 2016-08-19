#!/bin/sh

export CLST_ENV="csg"
export BAM_DB_ID=42
export BAM_CENTER="broad"
export BAM_PI="test"
export BAM_HOST="topmed5"

for bam in $*; do
  export DELAY=$(($RANDOM % 120))
  export BAM_FILE=$bam
  export SAMPLE_ID="$(/usr/cluster/bin/samtools view -H $bam| grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2)"

  job_name="b38-2-b37-test-${SAMPLE_ID}"
  echo "Submitting BAM: $BAM_FILE for alignment with SAMPLE_ID: $SAMPLE_ID with initial DELAY: $DELAY"
  sbatch -J $job_name batch.d/b38-2-b37.sh
done
