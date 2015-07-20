#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --time=28-0
#SBATCH --partition=nomosix
#SBATCH --mail-type=ALL
#SBATCH --mail-user=schelcj@umich.edu

#PBS -l qos=flux,proces=1,walltime=672:00:00,mem=1gb
#PBS -m abe
#PBS -M schelcj@umich.edu
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe

if [ ! -z $SLURM_JOB_ID ]; then
  JOB_ID=$SLURM_JOB_ID
  CLST_ENV="csg"
  PREFIX="/net/topmed/working"
  QUEUE_CMD="squeue -h -o %L -j"
  SUBMIT_CMD="sbatch"

elif [ ! -z $PBS_JOBID ]; then
  JOB_ID=$PBS_JOBID
  CLST_ENV="flux"
  PREFIX="/dept/csg/topmed/working"
  QUEUE_CMD="showq"
  SUBMIT_CMD="qsub"

else
  echo "Unknown cluster environment"
  exit 1
fi

PROJECT_DIR="${PREFIX}/schelcj/align"
TOPMED_CMD="${PROJECT_DIR}/bin/topmed"

export PERL5LIB=${PROJECT_DIR}/local.${CLST_ENV}/lib/perl5:$PERL5LIB
export PERL_CARTON_PATH=${PROJECT_DIR}/local.${CLST_ENV}

while true; do
  sleep 5

  time_left="$($QUEUE_CMD $JOB_ID)"

  # XXX - what could possibly go wrong with this?!
  case "$CLST_ENV")
    'csg')
      # XXX - format: dd-hh:mm:ss
      time_remaining=$(squeue -h -o %L -j $JOB_ID | perl -nle 'print $1 if /(?:\d{1,2}\-)?(\d{1,2}):\d{2}(?::\d{2})?/')
      ;;
    'flux')
      # XXX - format:  dd:hh:mm:ss
      time_remaining=$(showq | grep $JOB_ID | awk {'print $5'} | perl -nle 'print $1 if /(\d{1,2}):\d{2}:\d{2}?(?::\d{2})?/')
      ;;
  esac

  # TODO - figure out how to do time left
  if [ $time_remaining -gt 1 ]; then
    echo "Time Remaining: $time_remaining launching more jobs"
    $TOPMED_CMD launch -v -c $CLST_ENV
  else
    echo "Time Remaining: $time_remaining restarting and exiting"
    $SUBMIT_CMD $0
    exit 0
  fi
done
