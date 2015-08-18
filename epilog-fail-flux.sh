#!/bin/sh
#
# http://docs.adaptivecomputing.com/torque/4-0-2/Content/topics/12-appendices/scriptEnvironment.htm
#
# add with -l resource line
# #PBS -l epilogue.precancel=/dept/csg/topmed/working/schelcj/align/epilog-fail-flux.sh

JOB_ID=$1
PROJECT_DIR="/dept/csg/topmed/working/schelcj/align"

export PERL_CARTON_PATH=${PROJECT_DIR}/local.flux
export PERL5LIB=${PERL_CARTON_PATH}/lib/perl5:${PROJECT_DIR}/lib/perl5:$PERL5LIB
export PATH=${PROJECT_DIR}/bin:${PATH}

echo "[$(date)] Marking $job_id failed"
topmed update --verbose --jobid $job_id --state failed
exit 0
