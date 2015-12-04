#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=12
#SBATCH --mem=64000
#SBATCH --gres=tmp:sata:200
#SBATCH --time=28-00:00:00
#SBATCH --workdir=/net/topmed/working/gecco/mapping.logs
#SBATCH --partition=nomosix
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=schelcj@umich.edu

#PBS -l nodes=1:ppn=4,walltime=242:00:00,pmem=4gb
#PBS -l ddisk=50gb
#PBS -m a
#PBS -d /dept/csg/topmed/working/gecco/mapping.logs
#PBS -M schelcj@umich.edu
#PBS -q flux
#PBS -l qos=flux
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe

TMP_DIR="/tmp/gecco"
RUN_DIR="/net/topmed/working/gecco/mapping.run"
GOTCLOUD_CONF="/net/topmed/working/schelcj/align/gotcloud.conf.csg"
PIPELINE="bam2fastq"
BAM_CENTER="gecco"
BAM_HOST="topmed"

echo "[$(date)] Starting remapping pipeline"

if [ -z $BAM_FILE ]; then
  echo "[$(date)] BAM_FILE is not defined!"
  exit 1
fi

if [ -z $SAMPLE_ID ]; then
  echo "[$(date)] SAMPLE_ID is not defined!"
  exit 1
fi

if [ ! -z $SLURM_JOB_ID ]; then
  JOB_ID=$SLURM_JOB_ID
  NODE=$SLURM_JOB_NODELIST
  CLST_ENV="csg"
  PREFIX="/net"
  ALIGN_THREADS=12

  if [ -d $TMP_DIR ]; then
    for id in $(ls -1 $TMP_DIR); do
      job_state="$(sacct -j $id -X -n -o state%7)"
      if [ "$job_state" != "RUNNING " ]; then # XXX - left trailing space on purpose
        echo "[$(date)] Removing stale job tmp directory for job id: $id"
        rm -rf $TMP_DIR/$id
      fi
    done
  fi

elif [ ! -z $PBS_JOBID ]; then
  JOB_ID=$PBS_JOBID
  NODE="$(cat $PBS_NODEFILE)"
  CLST_ENV="flux"
  PREFIX="/dept/csg"
  ALIGN_THREADS=4

  if [ -d $TMP_DIR ]; then
    for id in $(ls -1 $TMP_DIR); do
      qstat -f -e $id > /dev/null 2>&1
      if [ $? -ne 0 ]; then
        echo "[$(date)] Removing stale job tmp directory for job id: $id"
        rm -rf $TMP_DIR/$id
      fi
    done
  fi

else
  echo "[$(date)] Unknown cluster environment"
  exit 1
fi

REF_DIR="${PREFIX}/topmed/working/mktrost/gotcloud.ref"
TMP_DIR="${TMP_DIR}/${JOB_ID}"
FASTQ_LIST="${TMP_DIR}/fastq.list"
BAM_LIST="${TMP_DIR}/bam.list"
OUT_DIR="${PREFIX}/${BAM_HOST}/working/${BAM_CENTER}/mapping.results/${SAMPLE_ID}"
JOB_LOG="${OUT_DIR}/job_log"

echo "[$(date)]
OUT_DIR:    $OUT_DIR
TMP_DIR:    $TMP_DIR
REF_DIR:    $REF_DIR
RUN_DIR:    $RUN_DIR
BAM:        $BAM_FILE
SAMPLE_ID:  $SAMPLE_ID
BAM_CENTER: $BAM_CENTER
BAM_LIST:   $BAM_LIST
BAM_HOST:   $BAM_HOST
FASTQ_LIST: $FASTQ_LIST
NODE:       $NODE
JOBID:      $JOB_ID
GOTCLOUD:   $(which gotcloud)
PIPELINE:   $PIPELINE
GC_CONF:    $GOTCLOUD_CONF
"

if [ -e $OUT_DIR ]; then
  echo "[$(date)] Found existing OUT_DIR deleting"
  rm -rfv $OUT_DIR

  if [ $? -ne 0 ]; then
    echo "[$(date)] Failed to remove existing OUT_DIR"
    exit 1
  fi
fi

echo "[$(date)] Creating OUT_DIR and TMP_DIR"
mkdir -p $OUT_DIR $TMP_DIR

if [ $? -ne 0 ]; then
  echo "[$(date)] Failed to create OUT_DIR and or TMP_DIR"
  exit 1
fi

echo "[$(date)] Setting permissions on TMP_DIR"
chmod 750 $TMP_DIR

if [ $? -ne 0 ]; then
  echo "[$(date)] Failed to set permissions on TMP_DIR"
  exit 1
fi

echo "[$(date)] Creating BAM_LIST"
echo "$SAMPLE_ID $BAM_FILE" > $BAM_LIST

echo "[$(date)] Recording job info"
echo "---" >> $JOB_LOG
echo "start: $(date)" >> $JOB_LOG
echo "jobid: $JOB_ID" >> $JOB_LOG
echo "out_dir: $OUT_DIR" >> $JOB_LOG
echo "tmp_dir: $TMP_DIR" >> $JOB_LOG
echo "ref_dir: $REF_DIR" >> $JOB_LOG
echo "run_dir: $RUN_DIR" >> $JOB_LOG
echo "pipeline: $PIPELINE" >> $JOB_LOG
echo "gc_conf: $GOTCLOUD_CONF" >> $JOB_LOG
echo "gotcloud: $(which gotcloud)" >> $JOB_LOG
echo "delay: $DELAY" >> $JOB_LOG
echo "bam: $BAM_FILE" >> $JOB_LOG
echo "sample_id: $SAMPLE_ID" >> $JOB_LOG
echo "bam_center: $BAM_CENTER" >> $JOB_LOG
echo "bam_list: $BAM_LIST" >> $JOB_LOG
echo "bam_host: $BAM_HOST" >> $JOB_LOG
echo "fastq_list: $FASTQ_LIST" >> $JOB_LOG
echo "cluster: $CLST_ENV" >> $JOB_LOG
echo "node: $NODE" >> $JOB_LOG

if [ ! -z $DELAY ]; then
  echo "[$(date)] Delaying execution for ${DELAY} minutes"
  sleep ${DELAY}m
fi

echo "[$(date)] Beginning gotcloud pipeline"
gotcloud pipe              \
  --name    $PIPELINE      \
  --conf    $GOTCLOUD_CONF \
  --numjobs 1              \
  --ref_dir $REF_DIR       \
  --outdir  $TMP_DIR

rc=$?

echo "pipe_rc: $rc" >> $JOB_LOG

if [ "$rc" -ne 0 ]; then
  echo "[$(date)] $PIPELINE failed with exit code $rc" 1>&2
else
  echo "[$(date)] Begining gotcloud alignment"
  gotcloud align                   \
    --conf      $GOTCLOUD_CONF     \
    --threads   $ALIGN_THREADS     \
    --outdir    $OUT_DIR           \
    --fastqlist $FASTQ_LIST        \
    --override  "TMP_DIR=$TMP_DIR" \
    --ref_dir   $REF_DIR

  rc=$?
  echo "align_rc: $rc" >> $JOB_LOG

  if [ "$rc" -ne 0 ]; then
    echo "[$(date)] Alignment failed with exit code $rc" 1>&2
  else
    echo "[$(date)] Alignment completed"
  fi
fi

if [ "$rc" -ne 0 ]; then
  echo "[$(date)] Alignment failed, moving TMP_DIR to RUN_DIR"
  mv $TMP_DIR $RUN_DIR

  max_runs=10
  run_count=$(find $RUN_DIR -maxdepth 1 -type d|wc -l)
  runs=$(find $RUN_DIR/* -maxdepth 1 -type d|sort)

  if [ $run_count -gt $max_runs ]; then
    count=0
    for run in $runs; do
      if [ $(($run_count - $max_runs)) -gt $count ]; then
        echo "[$(date)] Purging run [$(basename $run)] from RUN_DIR"
        rm -rf $run
      fi

      count=$(($count + 1))
    done
  fi
else
  echo "[$(date)] Purging $TMP_DIR on $NODE"
  rm -rf $TMP_DIR
fi

echo "[$(date)] Exiting [RC: $rc]"
echo "end: $(date)" >> $JOB_LOG
exit $rc
