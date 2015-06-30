#!/bin/sh

# TODO
#  * TMP_DIR might be /tmp or /fasttmp if running on csg cluster
#    need a way to control that from the outside of the batch script
#  * /tmp will be controlled by slurm as --tmp=
#  * /fasttmp will be a gres controlled by --gres=
#  * change output directory to per job per center per pi
#  * could make this determine what bam to run on its own

#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=6
#SBATCH --mem=15000
#SBATCH --tmp=150000
#SBATCH --time=10-0
#SBATCH --workdir=./run
#SBATCH --partition=topmed
#SBATCH --ignore-pbs

#PBS -l nodes=1:ppn=2,walltime=240:00:00,pmem=8gb
#PBS -l ddisk=150gb
#PBS -m abe
#PBS -d .
#PBS -M schelcj@umich.edu
#PBS -q fluxm
#PBS -l qos=flux
#PBS -A boehnke_flux
#PBS -V
#PBS -j oe

PROJECT_DIR="$HOME/projects/topmed"
RUN_DIR="$PROJECT_DIR/run"
SAMPLE_DIR="$RUN_DIR/samples"
CONF="$PROJECT_DIR/gotcloud.conf"
OUT_DIR="topmed/working/schelcj/align.results"
REF_DIR="topmed/working/mktrost/gotcloud.ref"
TMP_DIR="/tmp/topmed"
GOTCLOUD_ROOT="$HOME/projects/topmed/gotcloud"
PIPELINE="bam2fastq"

export PATH=$GOTCLOUD_ROOT:$PATH

if [ -z $BAM_CENTER ]; then
  echo "BAM_CENTER is not defined!"
  exit 1
fi

if [ -z $BAM_FILE ]; then
  echo "BAM_FILE is not defined!"
  exit 1
fi

if [ ! -z $SLURM_JOB_ID ]; then
  OUT_DIR="/net/${OUT_DIR}/${BAM_CENTER}/${SLURM_JOB_ID}"
  TMP_DIR="${TMP_DIR}/${SLURM_JOB_ID}"
  REF_DIR="/net/${REF_DIR}"
  NODE=$SLURM_JOB_NODELIST
  JOB_ID=$SLURM_JOB_ID
elif [ ! -z $PBS_JOBID ]; then
  OUT_DIR="/dept/csg/${OUT_DIR}/${BAM_CENTER}/${PBS_JOBID}"
  TMP_DIR="${TMP_DIR}/${PBS_JOBID}"
  REF_DIR="/dept/csg/${REF_DIR}"
  NODE=$PBS_NODELIST # FIXME - not sure what this is yet
  JOB_ID=$PBS_JOBID
fi

case "$BAM_CENTER" in
  uw)
    PIPELINE="cleanUpBam2fastq"
    ;;
esac

mkdir -p $OUT_DIR $TMP_DIR $SAMPLE_DIR

function print_job_info() {
  echo "OUT_DIR:  $OUT_DIR"
  echo "TMP_DIR:  $TMP_DIR"
  echo "REF_DIR:  $REF_DIR"
  echo "BAM:      $BAM_FILE"
  echo "BAM ID:   $1"
  echo "NODE:     $NODE"
  echo "JOBID:    $JOB_ID"
  echo "GOTCLOUD: $(which gotcloud)"
  echo "GC CONF:  $CONF"
  echo "PIPELINE: $PIPELINE"
}

bam_id="$(samtools view -H $BAM_FILE | grep '^@RG' | grep -o 'SM:\w*' | sort -u | cut -d \: -f 2)"
job_info=${SAMPLE_DIR}/$(basename $BAM_FILE)

if [ -e $job_info]; then
  echo "Already processed this sample"
  exit 1
fi

echo "$bam_id\t$BAM_FILE" > $TMP_DIR/bam.list

print_job_info "$bam_id" > $job_info
print_job_info "$bam_id"

gotcloud pipe                \
  --gcroot  $GOTCLOUD_ROOT   \
  --name    $PIPELINE        \
  --conf    $CONF            \
  --numjobs 1                \
  --ref_dir $REF_DIR         \
  --outdir  $TMP_DIR

rc=$?

if [ "$rc" -ne 0 ]; then
  echo "cleanUpBam2fastq failed" 1>&2
  exit $rc
fi

gotcloud align                    \
  --gcroot    $GOTCLOUD_ROOT      \
  --conf      $CONF               \
  --threads   6                   \
  --outdir    $OUT_DIR            \
  --fastqlist $TMP_DIR/fastq.list \
  --override "TMP_DIR=$TMP_DIR"   \
  --ref_dir   $REF_DIR

rc=$?

if [ "$rc" -ne 0 ]; then
  echo "Alighment failed; job info is in $job_info"
  exit $rc
fi

rm -rf $TMP_DIR
