#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --time=28-0
#SBATCH --partition=topmed
#SBATCH --mail-type=ALL
#SBATCH --mail-user=schelcj@umich.edu
#SBATCH --workdir=../logs/monitor
#SBATCH --job-name=monitor-topmed

#PBS -l qos=flux,proces=1,walltime=672:00:00,mem=1gb
#PBS -m abe
#PBS -M schelcj@umich.edu
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe
#PBS -d ../logs/monitor
#PBS -N monitor-topmed

if [ ! -z $SLURM_JOB_ID ]; then
  CLST_ENV="csg"
  PREFIX="/net/topmed/working"
  SUBMIT_CMD="sbatch"

elif [ ! -z $PBS_JOBID ]; then
  CLST_ENV="flux"
  PREFIX="/dept/csg/topmed/working"
  SUBMIT_CMD="qsub"

else
  echo "Unknown cluster environment"
  exit 1
fi

PROJECT_DIR="${PREFIX}/schelcj/align"
CONTROL_DIR="${PROJECT_DIR}/control"

export PATH=${PROJECT_DIR}/bin:$PATH
export PERL_CARTON_PATH=${PROJECT_DIR}/local.${CLST_ENV}
export PERL5LIB=${PERL_CARTON_PATH}/lib/perl5:$PERL5LIB

while true; do
  case "$CLST_ENV" in
    csg)
      TIME_REMAINING=$(squeue -h -o %L -j $SLURM_JOB_ID)
      ;;
    flux)
      TIME_REMAINING=$(showq | grep $PBS_JOBID| awk {'print $5'})
      ;;
  esac

  remaining=$(topmed stat --time_left $TIME_REMAINING)
  job_limit=$(cat ${CONTROL_DIR}/monitor_max_jobs_launch)
  min_time_left=$(cat ${CONTROL_DIR}/monitor_min_time_left)
  sleep_delay=$(cat ${CONTROL_DIR}/monitor_sleep)

  if [ $remaining -gt $min_time_left ]; then
    echo "Launching $job_limit more job(s) [Remaining: ${remaining}h]"
    topmed launch -v -c $CLST_ENV -l $job_limit
  else
    echo "Resubmitting and exiting [Remaining: ${remaining}h]"
    $SUBMIT_CMD $PROJECT_DIR/monitor.sh
    exit 0
  fi

  echo "Sleeping for $sleep_delay before launching more jobs"
  sleep $sleep_delay
done
