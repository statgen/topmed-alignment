#!/bin/sh

#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=6
#SBATCH --mem=15000
#SBATCH --tmp=150000
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
SAMPLE_DIR="${RUN_DIR}/samples"
TMP_DIR="${TMP_DIR}/${JOB_ID}"
CONF="${PROJECT_DIR}/gotcloud.conf"
GOTCLOUD_ROOT="${PROJECT_DIR}/../gotcloud"
GOTCLOUD_CMD="gotcloud"

case "$CLST_ENV")
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
esac

export PATH=$GOTCLOUD_ROOT:$PATH
mkdir -p $OUT_DIR $TMP_DIR $SAMPLE_DIR

bam_id="$(samtools view -H $BAM_FILE | grep '^@RG' | grep -o 'SM:\w*' | sort -u | cut -d \: -f 2)"
job_info=${SAMPLE_DIR}/$(basename $BAM_FILE)

if [ -e $job_info ]; then
  echo "Already processed this sample"
  exit 1
fi

echo "$bam_id\t$BAM_FILE" > $TMP_DIR/bam.list

echo "OUT_DIR:    $OUT_DIR" > $job_info
echo "TMP_DIR:    $TMP_DIR" >> $job_info
echo "REF_DIR:    $REF_DIR" >> $job_info
echo "BAM:        $BAM_FILE" >> $job_info
echo "BAM ID:     $bam_id" >> $job_info
echo "BAM CENTER: $BAM_CENTER" >> $job_info
echo "NODE:       $NODE" >> $job_info
echo "JOBID:      $JOB_ID" >> $job_info
echo "GOTCLOUD:   $(which gotcloud)" >> $job_info
echo "PIPELINE:   $PIPELINE" >> $job_info
echo "GC CONF:    $CONF" >> $job_info

$GOTCLOUD_CMD pipe           \
  --gcroot  $GOTCLOUD_ROOT   \
  --name    $PIPELINE        \
  --conf    $CONF            \
  --numjobs 1                \
  --ref_dir $REF_DIR         \
  --outdir  $TMP_DIR

rc=$?

echo "GC PIPE RC: $rc" >> $job_info

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

echo "GC ALIGN RC: $rc" >> $job_info

if [ "$rc" -ne 0 ]; then
  echo "Alighment failed; job info is in $job_info"
  exit $rc
fi

rm -rf $TMP_DIR
