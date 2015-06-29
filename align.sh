#!/bin/sh

#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=6
#SBATCH --mem=15000
#SBATCH --tmp=150000
# SBATCH --gres=SSD:fasttmp:150
#SBATCH --time=10-0
#SBATCH --workdir=./run
#SBATCH --ignore-pbs
#SBATCH --partition=topmed

#PBS -l nodes=1:ppn=2,walltime=240:00:00,pmem=25gb
#PBS -l ddisk=150gb
#PBS -m abe
#PBS -d .
#PBS -M schelcj@umich.edu
#PBS -q fluxm
#PBS -l qos=flux
#PBS -A boehnke_fluxm
#PBS -V
#PBS -j oe

CONF="$HOME/projects/topmed/gotcloud.conf"
OUT_DIR="topmed/working/schelcj/out.uw"
REF_DIR="topmed/working/mktrost/gotcloud.ref"
TMP_DIR="/tmp/topmed"
GOTCLOUD_ROOT="$HOME/projects/topmed/gotcloud"
PIPELINE="bam2fastq"

export PATH=$GOTCLOUD_ROOT:$PATH

if [ ! -z $SLURM_JOB_ID ]; then
  OUT_DIR="/net/${OUT_DIR}"
  TMP_DIR="${TMP_DIR}/${SLURM_JOB_ID}"
  REF_DIR="/net/${REF_DIR}"
else
  OUT_DIR="/dept/csg/${OUTDIR}"
  TMP_DIR="${TMP_DIR}/${PBS_JOBID}"
  REF_DIR="/dept/csg/${REF_DIR}"
fi

case "$BAM_CENTER" in
  uw)
    PIPELINE="cleanUpBam2Fastq"
    ;;
esac

mkdir -p $OUTDIR $TMP_DIR

sample="$(samtools view -H $BAM_FILE | grep '^@RG' | grep -o 'SM:\w*' | sort -u | cut -d \: -f 2)"
echo "$sample\t$BAM_FILE" > $TMP_DIR/bam.list

echo "OUT_DIR: $OUT_DIR"
echo "TMP_DIR: $TMP_DIR"
echo "REF_DIR: $REF_DIR"
echo "GC CONF: $CONF"
echo "GOTCLOUD: $(which gotcloud)"
echo "BAM: $BAM_FILE"
echo "NODE: $SLURM_JOB_NODELIST"

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
  --gcroot  $GOTCLOUD_ROOT        \
  --conf    $CONF                 \
  --threads   6                   \
  --outdir    $OUT_DIR            \
  --fastqlist $TMP_DIR/fastq.list \
  --override "TMP_DIR=$TMP_DIR"   \
  --ref_dir   $REF_DIR

rc=$?

if [ "$rc" -ne 0 ]; then
  echo "Alignment failed, TMP_DIR is $TMP_DIR on host $SLURM_JOB_NODELIST"
  exit $rc
fi

rm -rf $TMP_DIR

# TODO
#  * TMP_DIR might be /tmp or /fasttmp if running on csg cluster
#    need a way to control that from the outside of the batch script
#  * /tmp will be controlled by slurm as --tmp=
#  * /fasttmp will be a gres controlled by --gres=
