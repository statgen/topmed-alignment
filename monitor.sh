#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --time=28-0
#SBATCH --partition=nomosix
#SBATCH --mail-type=ALL
#SBATCH --mail-user=schelcj@umich.edu
#SBATCH --workdir=../run

#PBS -l qos=flux,proces=1,walltime=672:00:00,mem=1gb
#PBS -m abe
#PBS -M schelcj@umich.edu
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe
#PBS -d ../run

if [ ! -z $SLURM_JOB_ID ]; then
  CLST_ENV="csg"
  PREFIX="/net/topmed/working"
  SUBMIT_CMD="sbatch"
  TIME_REMAINING=$(squeue -h -o %L -j $SLURM_JOB_ID)

elif [ ! -z $PBS_JOBID ]; then
  CLST_ENV="flux"
  PREFIX="/dept/csg/topmed/working"
  SUBMIT_CMD="qsub"
  TIME_REMAINING=$(showq | grep $PBS_JOBID| awk {'print $5'})

else
  echo "Unknown cluster environment"
  exit 1
fi

PROJECT_DIR="${PREFIX}/schelcj/align"

export PATH=${PROJECT_DIR}/bin:$PATH
export PERL_CARTON_PATH=${PROJECT_DIR}/local.${CLST_ENV}
export PERL5LIB=${PERL_CARTON_PATH}/lib/perl5:$PERL5LIB

while true; do
  remaining=$(topmed stat --time_left $TIME_REMAINING)

  if [ $remaining -gt 1 ]; then
    echo "Launching more job(s) [Remaining: ${remaining}h]"
    topmed launch -v -c $CLST_ENV -l 100
  else
    echo "Resubmitting and exiting [Remaining: ${remaining}h]"
    $SUBMIT_CMD $0
    exit 0
  fi

  sleep 15m
done
