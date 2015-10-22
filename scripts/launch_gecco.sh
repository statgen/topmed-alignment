#!/bin/sh

#BAMS=($(awk {'print $3'} /net/esp/saichen/allYears/allYears.bam.index))

BAMS=($(cat /working/gecco/mapping.logs/20151012/failed/samples.txt))

for bam in "${BAMS[@]}"; do
  export DELAY=$(($RANDOM % 120))
  export BAM_FILE=$bam
  export SAMPLE_ID="$(samtools view -H $bam| grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2)"

  if [ $SAMPLE_ID != '63305' ]; then
    echo "Submitting BAM: $BAM_FILE for alignment with SAMPLE_ID: $SAMPLE_ID with initial DELAY: $DELAY"
    sbatch -J "gecco-${SAMPLE_ID}" batch.d/gecco.sh
  fi
done
