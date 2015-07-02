#!/bin/sh

#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=6
#SBATCH --mem=15000
#SBATCH --tmp=300000
#SBATCH --time=10-0
#SBATCH --workdir=../run
#SBATCH --partition=topmed
#SBATCH --ignore-pbs

#PBS -l nodes=1:ppn=2,walltime=240:00:00,pmem=8gb
#PBS -l ddisk=150gb
#PBS -m abe
#PBS -d ../run
#PBS -M schelcj@umich.edu
#PBS -q flux
#PBS -l qos=flux
#PBS -A sph_flux
#PBS -V
#PBS -j oe

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

elif [ ! -z $PBS_JOBID ]; then
  JOB_ID=$PBS_JOBID
  NODE="$(cat $PBS_NODEFILE)"
  CLST_ENV="flux"
  PREFIX="/dept/csg/topmed/working"

else
  echo "Unknown cluster environment"
  exit 1
fi

TMP_DIR="/tmp/topmed"
PIPELINE="bam2fastq"
ALIGN_THREADS=6

PROJECT_DIR="${PREFIX}/schelcj/align"
REF_DIR="${PREFIX}/mktrost/gotcloud.ref"
OUT_DIR="${PREFIX}/schelcj/results/${BAM_CENTER}/${JOB_ID}"
RUN_DIR="${PROJECT_DIR}/../run"
LOG_DIR="${PROJECT_DIR}/../logs"
TMP_DIR="${TMP_DIR}/${JOB_ID}"
CONF="${PROJECT_DIR}/gotcloud.conf"
GOTCLOUD_ROOT="${PROJECT_DIR}/../gotcloud"
GOTCLOUD_CMD="gotcloud"

case "$CLST_ENV" in
  csg)
    GOTCLOUD_CMD="srun gotcloud"
    ;;
  flux)
    GOTCLOUD_ROOT="${PROJECT_DIR}/gotcloud.flux"
    ALIGN_THREADS=2
    ;;
esac

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

export PATH=$GOTCLOUD_ROOT:$PATH
mkdir -p $OUT_DIR $TMP_DIR $LOG_DIR

bam_id="$(samtools view -H $BAM_FILE | grep '^@RG' | grep -o 'SM:\w*' | sort -u | cut -d \: -f 2)"
job_log=${LOG_DIR}/$(basename $BAM_FILE)

if [ -e $job_log ]; then
  echo "Already processed this sample"
  exit 1
fi

echo "$bam_id\t$BAM_FILE" > $TMP_DIR/bam.list

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
GC CONF:    $CONF" > $job_log

$GOTCLOUD_CMD pipe           \
  --gcroot  $GOTCLOUD_ROOT   \
  --name    $PIPELINE        \
  --conf    $CONF            \
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
  --conf      $CONF               \
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
