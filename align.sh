#!/bin/sh

#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=6
#SBATCH --mem=15000
#SBATCH --gres=tmp:sata:200
#SBATCH --time=10-0
#SBATCH --workdir=../run
#SBATCH --partition=nomosix
#SBATCH --ignore-pbs

#PBS -l nodes=1:ppn=2,walltime=240:00:00,pmem=8gb
#PBS -l ddisk=200gb
#PBS -m abe
#PBS -d ../run
#PBS -M schelcj@umich.edu
#PBS -q flux
#PBS -l qos=flux
#PBS -A sph_flux
#PBS -V
#PBS -j oe

export PATH=/usr/cluster/bin:/usr/cluster/sbin:$PATH # XXX - temp hack till old binaries are purged

TMP_DIR="/tmp/topmed"
PIPELINE="bam2fastq"
ALIGN_THREADS=6
GOTCLOUD_CMD="gotcloud"

if [ -z $BAM_CENTER ]; then
  echo "BAM_CENTER is not defined!"
  exit 1
fi

if [ -z $BAM_FILE ]; then
  echo "BAM_FILE is not defined!"
  exit 1
fi

if [ ! -z $SLURM_JOB_ID ]; then
  JOB_ID=$SLURM_JOB_ID
  NODE=$SLURM_JOB_NODELIST
  CLST_ENV="csg"
  PREFIX="/net/topmed/working"

  for job in $(ls -1 $TMP_DIR); do
    squeue -h -o %i -j $job 1>/dev/null 2>/dev/null
    if  [ "$?" -eq 1 ]; then
      echo "Removing stale job tmp directory for job id: $job"
      rm -rf $TMP_DIR/$job
    fi
  done

elif [ ! -z $PBS_JOBID ]; then
  JOB_ID=$PBS_JOBID
  NODE="$(cat $PBS_NODEFILE)"
  CLST_ENV="flux"
  PREFIX="/dept/csg/topmed/working"
  ALIGN_THREADS=2

  # TODO - find/delete stale tmp job directories

else
  echo "Unknown cluster environment"
  exit 1
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
esac

TMP_DIR="${TMP_DIR}/${JOB_ID}"
PROJECT_DIR="${PREFIX}/schelcj/align"
REF_DIR="${PREFIX}/mktrost/gotcloud.ref"
OUT_DIR="${PREFIX}/schelcj/results/${BAM_CENTER}/${JOB_ID}"
RUN_DIR="${PROJECT_DIR}/../run"
LOG_DIR="${PROJECT_DIR}/../logs"
GOTCLOUD_CONF="${PROJECT_DIR}/gotcloud.conf.${CLST_ENV}"
GOTCLOUD_ROOT="${PROJECT_DIR}/../gotcloud.${CLST_ENV}"

export PATH=$GOTCLOUD_ROOT:$PATH
mkdir -p $OUT_DIR $TMP_DIR $LOG_DIR

bam_id="$(samtools view -H $BAM_FILE | grep '^@RG' | grep -o 'SM:\w*' | sort -u | cut -d \: -f 2)"
job_log=${LOG_DIR}/$(basename $BAM_FILE)

if [ -e $job_log ]; then
  echo "Already processed this sample"
  exit 1
fi

echo "
OUT_DIR:    $OUT_DIR
TMP_DIR:    $TMP_DIR
REF_DIR:    $REF_DIR
BAM:        $BAM_FILE
BAM ID:     $bam_id
BAM CENTER: $BAM_CENTER
NODE:       $NODE
JOBID:      $JOB_ID
GOTCLOUD:   $(which gotcloud)
PIPELINE:   $PIPELINE
GC CONF:    $GOTCLOUD_CONF" > $job_log

echo "$bam_id\t$BAM_FILE" > $TMP_DIR/bam.list

$GOTCLOUD_CMD pipe           \
  --gcroot  $GOTCLOUD_ROOT   \
  --name    $PIPELINE        \
  --conf    $GOTCLOUD_CONF   \
  --numjobs 1                \
  --ref_dir $REF_DIR         \
  --outdir  $TMP_DIR

rc=$?

echo "GC PIPE RC: $rc" >> $job_log

if [ "$rc" -ne 0 ]; then
  echo "cleanUpBam2fastq failed" 1>&2
  exit $rc
fi

$GOTCLOUD_CMD align               \
  --gcroot    $GOTCLOUD_ROOT      \
  --conf      $GOTCLOUD_CONF      \
  --threads   $ALIGN_THREADS      \
  --outdir    $OUT_DIR            \
  --fastqlist $TMP_DIR/fastq.list \
  --override "TMP_DIR=$TMP_DIR"   \
  --ref_dir   $REF_DIR

rc=$?

echo "GC ALIGN RC: $rc" >> $job_log

if [ "$rc" -ne 0 ]; then
  echo "Alighment failed; job info is in $job_log"
  exit $rc
fi

rm -rf $TMP_DIR
