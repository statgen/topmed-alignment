#!/bin/sh
#
#SBATCH --mail-type=ALL
#SBATCH --mail-user=schelcj@umich.edu
#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=2
#SBATCH --mem=25000
# SBATCH --tmp=150000
#SBATCH --time=10-0
#SBATCH --workdir=/net/dumbo/home/schelcj/projects/topmed
#SBATCH --ignore-pbs
#SBATCH --partition=topmed
#SBATCH --error=logs/slurm-%j.err
#SBATCH --output=logs/slurm-%j.out

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

export PATH=$PWD/gotcloud:$PATH

echo $(which gotcloud)

OUT_DIR="topmed/working/schelcj/out.uw"
REF_DIR="topmed/working/mktrost/gotcloud.ref"
TMP_DIR="/tmp/topmed"

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
echo -e "$sample\t$BAM_FILE" > $TMP_DIR/bam.list

gotcloud pipe                   \
  --name    cleanUpBam2fastq    \
  --conf    gotcloud.conf       \
  --numjobs 1                   \
  --ref_dir   $REF_DIR          \
  --outdir  $TMP_DIR

if [ "$?" -ne 0 ]; then
  echo "cleanUpBam2fastq failed" 1>&2
  exit
fi

gotcloud align                    \
  --conf      gotcloud.conf       \
  --threads   2                   \
  --outdir    $OUT_DIR            \
  --fastqlist $TMP_DIR/fastq.list \
  --override "TMP_DIR=$TMP_DIR"   \
  --ref_dir   $REF_DIR

# TODO
#  * create a bam.list for each individaul bam sample file
#  * set TMP_DIR on the comand line
#  * clean up TMP_DIR afterwards
#  * need someway of automagically knowning which BAM sample to work on or
#    being told externally, likely via ENV vars.
#    Likely env vars: SAMPLE_CENTER BAM_FILE
#  * TMP_DIR might be /tmp or /fasttmp if running on csg cluster
