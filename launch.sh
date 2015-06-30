#!/bin/sh

INCOMING="/net/topmed/incoming/topmed"
CENTERS=($(find $INCOMING -maxdepth 1))

for center in "${CENTERS[@]}"; do
  BAMS=($(find $center -name '*.bam' | head -n 100))
  BAM_CENTER=$(basename $center)

  if [ "$BAM_CENTER" == 'topmed' ] || [ "$BAM_CENTER" == 'illumina-upload' ]; then
    continue
  fi

  if [ "$BAM_CENTER" == 'illumina' ]; then
    export BAM_CENTER=$BAM_CENTER

    for bam in "${BAMS[@]}"; do
      export BAM_FILE=$bam

      sbatch ./align.sh
    done
  fi
done
