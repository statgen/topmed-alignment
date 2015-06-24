#!/bin/bash

#SBATCH --mail-type=ALL
#SBATCH --mail-user=schelcj@umich.edu
#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=2
#SBATCH --mem=25000
#SBATCH --tmp=150000
#SBATCH --time=10-0
#SBATCH --workdir=/net/dumbo/home/schelcj/projects/topmed
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

CONF="confs/gotcloud-uw.conf"
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
cp samples/uw-test1.txt $TMP_DIR/bam.list

gotcloud pipe                \
  --name    cleanUpBam2fastq \
  --conf    $CONF            \
  --numjobs 1                \
  --outdir  $TMP_DIR

gotcloud align                    \
  --conf      $CONF               \
  --threads   2                   \
  --outdir    $OUT_DIR            \
  --fastqlist $TMP_DIR/fastq.list \
  --ref_dir   $REF_DIR

# TODO
#  * create a bam.list for each individaul bam sample file
#  * set TMP_DIR on the comand line
#  * clean up TMP_DIR afterwards
#  * need someway of automagically knowning which BAM sample to work on or
#    being told externally, likely via ENV vars.
#    Likely env vars: SAMPLE_CENTER SAMPLE_FILE
