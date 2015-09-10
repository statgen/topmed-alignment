package Topmed::Job::Factory::Implementation::Requires;

use Moose::Role;

requires(
  qw(
    job_id
    elapsed
    elapsed_seconds
    state
    )
);

1;
