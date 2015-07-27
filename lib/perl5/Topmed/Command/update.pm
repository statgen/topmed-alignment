package Topmed::Command::update;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['bamid|b=i', 'ID From topmed db of BAM to update'],
    ['jobid|j=s', 'Record the job id that processed the BAM'],
    ['state|s=s', 'Mark the bam as [requested|failed|completed|cancelled]'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $conf  = Topmed::Config->new();
  my $cache = $conf->cache();

  unless ($opts->{bamid}) {
    $self->usage_error('BAM DB ID is required');
  }

  if ($opts->{state}) {
    unless (any {$opts->{state} eq $_} keys %BAM_STATUS) {
      $self->usage_error('Invalid state specificed');
    }
  }

  my $entry = $cache->entry($opts->{bamid});

  unless ($entry->exists) {
    $self->usage_error('BAM does not exist in cache');
  }

  $self->{stash}->{cache_entry} = $entry;

  if ($self->app->global_options->{help}) {
    print $self->app->usage->text;
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $entry = $self->{stash}->{cache_entry};
  my $bam   = $entry->thaw();

  $bam->{status} = $BAM_STATUS{$opts->{state}};

  if ($opts->{jobid}) {
    $bam->{job_id} = $opts->{jobid};
  }

  $entry->freeze($bam);
}

1;

__END__

=head1

Topmed::Command::update - Update the status of a BAM
