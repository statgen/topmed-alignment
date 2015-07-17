#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --time=28-0
#SBATCH --partition=nomosix

#PBS -l qos=flux,proces=1,walltime=672:00:00,mem=1gb
#PBS -m a
#PBS -M schelcj@umich.edu
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe

if [ ! -z $SLURM_JOB_ID ]; then
  JOB_ID=$SLURM_JOB_ID

elif [ ! -z $PBS_JOBID ]; then
  JOB_ID=$PBS_JOBID

else
  echo "Unknown cluster environment"
  exit 1
fi

# TODO - start infinite loop
# TODO - test if time is almost up
#         if it is resubmit myself and kill myself
#         if not, submit some more jobs

