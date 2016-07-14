#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --nodes=1-1
#SBATCH --cpus-per-task=6
#SBATCH --mem=48000
#SBATCH --gres=tmp:250
#SBATCH --time=28-0
#SBATCH --workdir=/net/topmed/working/schelcj/logs/align
#SBATCH --partition=topmed
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=topmed-alignment@umich.edu

#PBS -l nodes=1:ppn=6,walltime=242:00:00,pmem=4gb
#PBS -l ddisk=50gb
#PBS -m a
#PBS -d /dept/csg/topmed/working/schelcj/logs/align
#PBS -M topmed-alignment@umich.edu
#PBS -q flux
#PBS -l qos=flux
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe

echo "[$(date)] Starting remapping pipeline"

export PATH=/usr/cluster/bin:/usr/cluster/sbin:$PATH

TMP_DIR="/tmp/topmed"

if [ ! -z $SLURM_JOB_ID ]; then
  JOB_ID=$SLURM_JOB_ID
  NODE=$SLURM_JOB_NODELIST
  CLST_ENV="csg"
  PREFIX="/net"
  ALIGN_THREADS=6

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
  exit 10
fi

PROJECT_DIR="${PREFIX}/topmed/working/schelcj/align"
GOTCLOUD_CONF="${PROJECT_DIR}/gotcloud.conf.${CLST_ENV}"
GOTCLOUD_ROOT="${PROJECT_DIR}/../gotcloud.${CLST_ENV}"

export PERL_CARTON_PATH=${PROJECT_DIR}/local.${CLST_ENV}
export PERL5LIB=${PERL_CARTON_PATH}/lib/perl5:${PROJECT_DIR}/lib/perl5:$PERL5LIB
export PATH=${GOTCLOUD_ROOT}:${PROJECT_DIR}/bin:${PATH}

if [ -z $BAM_DB_ID ]; then
  echo "[$(date)] BAM_DB_ID is not defined!"
  exit 20
else
  echo "[$(date)] Updating database with current job id ($JOB_ID)"
  topmed update --bamid $BAM_DB_ID --jobid $JOB_ID
fi

if [ -z $BAM_CENTER ]; then
  echo "[$(date)] BAM_CENTER is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 30
fi

if [ -z $BAM_FILE ]; then
  echo "[$(date)] BAM_FILE is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 40
elif [ ! -e $BAM_FILE ]; then
  echo "[$(date)] BAM_FILE does not exist on disk!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 40
fi

if [ -z $BAM_PI ]; then
  echo "[$(date)] BAM_PI is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 50
fi

if [ -z $BAM_HOST ]; then
  echo "[$(date)] BAM_HOST is not defined!"
  topmed update --bamid $BAM_DB_ID --state failed
  exit 60
fi

case "$BAM_CENTER" in
  uw)
    PIPELINE="cleanUpBam2fastq"
    ;;
  broad)
    #PIPELINE="binBam2fastq"
    PIPELINE="cleanUpBam2fastq" # XXX - changed to fix some year1 samples
    ;;
  nygc)
    PIPELINE="binBam2fastq"
    ;;
  illumina)
    PIPELINE="cleanUpBam2fastq" # XXX - changed to fix some year1 samples
    ;;
  *)
    PIPELINE="bam2fastq"
    ;;
esac

REF_DIR="${PREFIX}/topmed/working/mktrost/gotcloud.ref"
TMP_DIR="${TMP_DIR}/${JOB_ID}"
FASTQ_LIST="${TMP_DIR}/fastq.list"
BAM_ID="$(samtools view -H $BAM_FILE | grep '^@RG' | grep -o 'SM:\S*' | sort -u | cut -d \: -f 2)"

if [ $? -ne 0 ]; then
  echo "[$(date)] Failed to determine sample id"
  exit
fi

if [ -z $BAM_ID ]; then
  echo "[$(date)] No sample id found"
  exit
fi

BAM_LIST="${TMP_DIR}/bam.list"
#OUT_DIR="${PREFIX}/${BAM_HOST}/working/schelcj/results/${BAM_CENTER}/${BAM_PI}/${BAM_ID}"
#OUT_DIR="${PREFIX}/topmed2/incoming/schelcj/results/${BAM_CENTER}/${BAM_PI}/${BAM_ID}" # XXX - per tom b. 11/30/2015
#OUT_DIR="${PREFIX}/topmed3/working/schelcj/results/${BAM_CENTER}/${BAM_PI}/${BAM_ID}" # XXX - per tom b. 01/14/2016
#OUT_DIR="${PREFIX}/topmed4/working/schelcj/results/${BAM_CENTER}/${BAM_PI}/${BAM_ID}" # XXX - per chris s. 03/25/2016
#OUT_DIR="${PREFIX}/topmed4/working/schelcj/test/${BAM_CENTER}/${BAM_PI}/${BAM_ID}" # XXX - debugging some failed samples - cjs 5/25/2016
OUT_DIR="${PREFIX}/topmed5/working/schelcj/results/${BAM_CENTER}/${BAM_PI}/${BAM_ID}" # XXX - rerunning samples with incorrect reads - cjs 7/13/2016
JOB_LOG="${OUT_DIR}/job_log"
RUN_DIR="${PROJECT_DIR}/../run"

echo "[$(date)]
OUT_DIR:    $OUT_DIR
TMP_DIR:    $TMP_DIR
REF_DIR:    $REF_DIR
RUN_DIR:    $RUN_DIR
BAM:        $BAM_FILE
BAM_ID:     $BAM_ID
BAM_CENTER: $BAM_CENTER
BAM_LIST:   $BAM_LIST
BAM_PI:     $BAM_PI
BAM_DB_ID:  $BAM_DB_ID
BAM_HOST:   $BAM_HOST
FASTQ_LIST: $FASTQ_LIST
NODE:       $NODE
JOBID:      $JOB_ID
GOTCLOUD:   $(which gotcloud)
PIPELINE:   $PIPELINE
GC_CONF:    $GOTCLOUD_CONF
GC_ROOT:    $GOTCLOUD_ROOT
"

if [ -e $OUT_DIR ]; then
  echo "[$(date)] Found existing OUT_DIR deleting"
  rm -rfv $OUT_DIR

  if [ $? -ne 0 ]; then
    echo "[$(date)] Failed to remove existing OUT_DIR"
    exit 70
  fi
fi

echo "[$(date)] Creating OUT_DIR and TMP_DIR"
mkdir -p $OUT_DIR $TMP_DIR

if [ $? -ne 0 ]; then
  echo "[$(date)] Failed to create OUT_DIR and or TMP_DIR"
  exit 80
fi

echo "[$(date)] Setting permissions on TMP_DIR"
chmod 750 $TMP_DIR

if [ $? -ne 0 ]; then
  echo "[$(date)] Failed to set permissions on TMP_DIR"
  exit 90
fi

echo "[$(date)] Creating BAM_LIST"
echo "$BAM_ID $BAM_FILE" > $BAM_LIST

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
echo "gc_root: $GOTCLOUD_ROOT" >> $JOB_LOG
echo "gotcloud: $(which gotcloud)" >> $JOB_LOG
echo "delay: $DELAY" >> $JOB_LOG
echo "bam: $BAM_FILE" >> $JOB_LOG
echo "bam_id: $BAM_ID" >> $JOB_LOG
echo "bam_center: $BAM_CENTER" >> $JOB_LOG
echo "bam_list: $BAM_LIST" >> $JOB_LOG
echo "bam_pi: $BAM_PI" >> $JOB_LOG
echo "bam_db_id: $BAM_DB_ID" >> $JOB_LOG
echo "bam_host: $BAM_HOST" >> $JOB_LOG
echo "fastq_list: $FASTQ_LIST" >> $JOB_LOG
echo "cluster: $CLST_ENV" >> $JOB_LOG
echo "node: $NODE" >> $JOB_LOG

if [ ! -z $DELAY ]; then
  echo "[$(date)] Delaying execution for ${DELAY} minutes"
  sleep "${DELAY}m"
fi

echo "[$(date)] Beginning gotcloud pipeline"
gotcloud pipe              \
  --gcroot  $GOTCLOUD_ROOT \
  --name    $PIPELINE      \
  --conf    $GOTCLOUD_CONF \
  --numjobs 1              \
  --ref_dir $REF_DIR       \
  --outdir  $TMP_DIR       \
  --verbose 1

rc=$?

echo "pipe_rc: $rc" >> $JOB_LOG

if [ "$rc" -ne 0 ]; then
  echo "[$(date)] $PIPELINE failed with exit code $rc" 1>&2
  topmed update --bamid $BAM_DB_ID --state failed
else

  if [ "$PIPELINE" == "cleanUpBam2fastq" ]; then
    echo "[$(date)] Puring temporary fastq files from $PIPELINE"
    rm -rf ${TMP_DIR}/fastqs/tmp.cleanUpBam

    if [ "$?" -ne 0 ]; then
      echo "[$(date)] Failed to delete temporary fastq files from $PIPELINE"
      topmed update --bamid $BAM_DB_ID --state failed
      exit 1
    fi
  fi

  echo "[$(date)] Begining gotcloud alignment"
  gotcloud align                   \
    --gcroot    $GOTCLOUD_ROOT     \
    --conf      $GOTCLOUD_CONF     \
    --threads   $ALIGN_THREADS     \
    --outdir    $OUT_DIR           \
    --fastqlist $FASTQ_LIST        \
    --override  "TMP_DIR=$TMP_DIR" \
    --ref_dir   $REF_DIR           \
    --verbose   1

  rc=$?
  echo "align_rc: $rc" >> $JOB_LOG

  if [ "$rc" -ne 0 ]; then
    echo "[$(date)] Alignment failed with exit code $rc" 1>&2
    topmed update --bamid $BAM_DB_ID --state failed
  else
    echo "[$(date)] Alignment completed"
    topmed update --bamid $BAM_DB_ID --state completed
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
