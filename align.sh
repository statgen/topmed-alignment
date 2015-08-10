#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=6
#SBATCH --mem=15000
#SBATCH --gres=tmp:sata:200
#SBATCH --time=10-02:00:00
#SBATCH --workdir=/net/topmed/working/schelcj/logs/align
#SBATCH --partition=nomosix
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=schelcj@umich.edu
#SBATCH --job-name=align-topmed

#PBS -l nodes=1:ppn=3,walltime=242:00:00,pmem=4gb
#PBS -l ddisk=200gb
#PBS -m a
#PBS -d /dept/csg/topmed/working/schelcj/logs/align
#PBS -M schelcj@umich.edu
#PBS -q flux
#PBS -l qos=flux
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe
#PBS -N align-topmed

echo "Starting remapping pipeline $(date)"

if [ ! -z $DELAY ]; then
  echo "Delaying execution for ${DELAY} minutes"
  sleep "${DELAY}m"
fi

export PATH=/usr/cluster/bin:/usr/cluster/sbin:$PATH

TMP_DIR="/tmp/topmed"

if [ ! -z $SLURM_JOB_ID ]; then
  JOB_ID=$SLURM_JOB_ID
  NODE=$SLURM_JOB_NODELIST
  CLST_ENV="csg"
  PREFIX="/net"
  ALIGN_THREADS=6

  for id in $(ls -1 $TMP_DIR); do
    job_state="$(sacct -j $id -X -n -o state%7)"
    if [ "$job_state" != "RUNNING " ]; then # XXX - left trailing space on purpose
      echo "Removing stale job tmp directory for job id: $id"
      rm -rf $TMP_DIR/$id
    fi
  done

elif [ ! -z $PBS_JOBID ]; then
  JOB_ID=$PBS_JOBID
  NODE="$(cat $PBS_NODEFILE)"
  CLST_ENV="flux"
  PREFIX="/dept/csg"
  ALIGN_THREADS=3

  for id in $(ls -1 $TMP_DIR); do
    checkjob -v $id 2 > /dev/null
    if [ $? -ne 0 ]; then
      echo "Removing stale job tmp directory for job id: $id"
      rm -rf $TMP_DIR/$id
    fi
  done

else
  echo "Unknown cluster environment"
  exit 10
fi

PROJECT_DIR="${PREFIX}/topmed/working/schelcj/align"
GOTCLOUD_CONF="${PROJECT_DIR}/gotcloud.conf.${CLST_ENV}"
GOTCLOUD_ROOT="${PROJECT_DIR}/../gotcloud.${CLST_ENV}"

export PERL_CARTON_PATH=${PROJECT_DIR}/local.${CLST_ENV}
export PERL5LIB=${PERL_CARTON_PATH}/lib/perl5:${PROJECT_DIR}/lib/perl5:$PERL5LIB
export PATH=${GOTCLOUD_ROOT}:${PROJECT_DIR}/bin:${PATH}

if [ -z $BAM_DB_ID ]; then
  echo "BAM_DB_ID is not defined!"
  exit 20
else
  echo "Updating cache with current job id"
  topmed update --bamid $BAM_DB_ID --jobid $JOB_ID
fi

if [ -z $BAM_CENTER ]; then
  echo "BAM_CENTER is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 30
fi

if [ -z $BAM_FILE ]; then
  echo "BAM_FILE is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 40
fi

if [ -z $BAM_PI ]; then
  echo "BAM_PI is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 50
fi

if [ -z $BAM_HOST ]; then
  echo "BAM_HOST is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 60
fi

case "$BAM_CENTER" in
  uw)
    PIPELINE="cleanUpBam2fastq"
    ;;
  broad)
    PIPELINE="binBam2fastq"
    ;;
  nygc)
    PIPELINE="binBam2fastq"
    ;;
  *)
    PIPELINE="bam2fastq"
    ;;
esac

REF_DIR="${PREFIX}/mktrost/gotcloud.ref"
TMP_DIR="${TMP_DIR}/${JOB_ID}"
FASTQ_LIST="${TMP_DIR}/fastq.list"
BAM_ID="$(samtools view -H $BAM_FILE | grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2)"
BAM_LIST="$TMP_DIR/bam.list"
OUT_DIR="${PREFIX}/$BAM_HOST/working/schelcj/results/${BAM_CENTER}/${BAM_PI}/${BAM_ID}"

echo "
OUT_DIR:    $OUT_DIR
TMP_DIR:    $TMP_DIR
REF_DIR:    $REF_DIR
BAM:        $BAM_FILE
BAM_ID:     $BAM_ID
BAM_CENTER: $BAM_CENTER
BAM_LIST:   $BAM_LIST
BAM_PI:     $BAM_PI
BAM_DB_ID:  $BAM_DB_ID
FASTQ_LIST: $FASTQ_LIST
NODE:       $NODE
JOBID:      $JOB_ID
GOTCLOUD:   $(which gotcloud)
PIPELINE:   $PIPELINE
GC_CONF:    $GOTCLOUD_CONF
GC_ROOT:    $GOTCLOUD_ROOT
"

echo "Creating OUT_DIR and TMP_DIR"
mkdir -p $OUT_DIR $TMP_DIR

echo "Creating BAM_LIST"
echo "$BAM_ID $BAM_FILE" > $BAM_LIST

echo "Beginning gotcloud pipeline"
gotcloud pipe              \
  --gcroot  $GOTCLOUD_ROOT \
  --name    $PIPELINE      \
  --conf    $GOTCLOUD_CONF \
  --numjobs 1              \
  --ref_dir $REF_DIR       \
  --outdir  $TMP_DIR

rc=$?

if [ "$rc" -ne 0 ]; then
  echo "$PIPELINE failed with exit code $rc" 1>&2
  topmed update --bamid $BAM_DB_ID --state failed
else
  echo "Begining gotcloud alignment"
  gotcloud align                   \
    --gcroot    $GOTCLOUD_ROOT     \
    --conf      $GOTCLOUD_CONF     \
    --threads   $ALIGN_THREADS     \
    --outdir    $OUT_DIR           \
    --fastqlist $FASTQ_LIST        \
    --override  "TMP_DIR=$TMP_DIR" \
    --ref_dir   $REF_DIR

  rc=$?

  if [ "$rc" -ne 0 ]; then
    echo "Alignment failed with exit code $rc" 1>&2
    topmed update --bamid $BAM_DB_ID --state failed
  else
    echo "Alignment completed"
    topmed update --bamid $BAM_DB_ID --state completed
  fi
fi

echo "Purging $TMP_DIR on $NODE"
rm -rf $TMP_DIR

echo "Exiting [RC: $rc]"
exit $rc
