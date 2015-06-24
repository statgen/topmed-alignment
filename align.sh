#!/bin/sh

#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=2
#SBATCH --mem=25000
#SBATCH --tmp=150000
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
  --name    cleanUpBam2fastq \
  --conf    $CONF            \
  --numjobs 1                \
  --ref_dir $REF_DIR         \
  --outdir  $TMP_DIR

if [ "$?" -ne 0 ]; then
  echo "cleanUpBam2fastq failed" 1>&2
  exit
fi

gotcloud align                    \
  --gcroot  $GOTCLOUD_ROOT        \
  --conf    $CONF                 \
  --threads   2                   \
  --outdir    $OUT_DIR            \
  --fastqlist $TMP_DIR/fastq.list \
  --override "TMP_DIR=$TMP_DIR"   \
  --ref_dir   $REF_DIR

#rm -rf $TMP_DIR

# TODO
#  * TMP_DIR might be /tmp or /fasttmp if running on csg cluster
