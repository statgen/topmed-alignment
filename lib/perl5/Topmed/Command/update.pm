package Topmed::Command::update;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::Job::Factory;

sub opt_spec {
  return (
    ['bamid|b=i',   'ID From topmed db of BAM to update'],
    ['jobid|j=s',   'Record the job id that processed the BAM'],
    ['state|s=s',   'Mark the bam as [requested|failed|completed|cancelled|submitted]'],
    ['cluster|c=s', 'Cluster that bam/job is running on [csg|flux]'],
    ['elapsed',     'Record the elapsed time for all completed jobs for the given cluster'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($opts->{elapsed}) {
    unless ($opts->{bamid} or $opts->{jobid}) {
      $self->usage_error('BAM DB ID or job id are required');
    }
  }

  if ($opts->{state}) {
    unless (any {$opts->{state} eq $_} keys %BAM_STATUS) {
      $self->usage_error('Invalid state specificed');
    }
  }

  if ($opts->{cluster} and $opts->{cluster} !~ /csg|flux/) {
    $self->usage_error('Invalid cluster specified');
  }

  if ($self->app->global_options->{help}) {
    say $self->usage->text;
    print $self->app->usage->text;
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $db  = Topmed::DB->new();
  my $bam = undef;

  if ($opts->{bamid}) {
    $bam = $db->resultset('Bamfile')->find($opts->{bamid});
    die "BAM [$opts->{bamid}] does not exist in the db" unless $bam;
  } elsif ($opts->{jobid}) {
    my $mapping = $db->resultset('Mapping')->search({job_id => {like => $opts->{jobid} . '%'}})->first;
    die "Job [$opts->{jobid}] does not exist in the db" unless $mapping;
    $bam = $mapping->bam;
  }

  if ($opts->{state}) {
    my $status = ($opts->{state} eq 'completed') ? time() : $BAM_STATUS{$opts->{state}};

    $bam->update({datemapping => $status});
    $bam->mapping->update(
      {
        status      => $status,
        modified_at => DateTime->now(),
      }
    );
  }

  if ($opts->{elapsed}) {
    die 'Required parameter(s) cluster missing' unless $opts->{cluster};

    my $maps = $db->resultset('Mapping')->search(
      {
        status   => {'>=' => $BAM_STATUS{completed}},
        cluster  => $opts->{cluster},
        walltime => 0,
      }
    );

    for my $map ($maps->all()) {
      my $job = Topmed::Job::Factory->create(ucfirst($opts->{cluster}), {job_id => $map->job_id});

      unless (defined $job->elapsed) {
        say 'No record walltime yet for job id [' . $map->job_id . ']' if $self->app->global_options->{verbose};
        next;
      }

      unless ($job->elapsed_seconds) {
        say 'No record walltime yet for job id [' . $map->job_id . ']' if $self->app->global_options->{verbose};
        next;
      }

      if ($self->app->global_options->{verbose}) {
        say 'Recorded walltime of ' . $job->elapsed_seconds . ' for job id ' . $map->job_id;
      }

      $map->update({walltime => $job->elapsed_seconds});
    }

    return;
  }

  if ($opts->{jobid} and $opts->{bamid}) {
    $bam->update({jobidmapping => $opts->{jobid}});
    $bam->mapping->update(
      {
        job_id      => $opts->{jobid},
        modified_at => DateTime->now(),
      }
    );
  }
}

1;

__END__

=head1

Topmed::Command::update - Update the status of a BAM
