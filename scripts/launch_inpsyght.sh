#!/bin/sh

BAMS=($(find /dept/csg/inpsyght/sequence_data/broad_bams/*.bam))

for bam in "${BAMS[@]}"; do
  export DELAY=$(($RANDOM % 120))
  export BAM_FILE=$bam
  export SAMPLE_ID="$(samtools view -H $bam| grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2)"

  echo "Submitting BAM: $BAM_FILE for alignment with SAMPLE_ID: $SAMPLE_ID with initial DELAY: $DELAY"
  qsub -N $SAMPLE_ID batch.d/inpsyght.sh
done
