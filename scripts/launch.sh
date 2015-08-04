#!/bin/sh

case "$1" in
  csg)
    PREFIX=/net/topmed
    CMD=sbatch
    ;;
  flux)
    PREFIX=/dept/csg/topmed
    CMD=qsub
    ;;
  *)
    echo "Usage: $0 [csg|flux] [limit] [chunk]"
    exit 1
esac

INCOMING="${PREFIX}/incoming/topmed"
CENTERS=($(find $INCOMING -maxdepth 1))

for center in "${CENTERS[@]}"; do
  BAMS=($(find $center -name '*.bam' | head -n $2 | tail -n $3))
  BAM_CENTER=$(basename $center)

  if [ "$BAM_CENTER" == 'topmed' ] || [ "$BAM_CENTER" == 'illumina-upload' ]; then
    continue
  fi

  if [ "$BAM_CENTER" == 'illumina' ]; then
    export BAM_CENTER=$BAM_CENTER

    for bam in "${BAMS[@]}"; do
      export BAM_FILE=$bam
      echo $BAM_FILE
      #$CMD ./align.sh
    done
  fi
done
