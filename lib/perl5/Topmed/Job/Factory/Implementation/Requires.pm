package Topmed::Job::Factory::Implementation::Requires;

use Moose::Role;

requires(
  qw(
    job_id
    elapsed
    state
    )
);

1;
