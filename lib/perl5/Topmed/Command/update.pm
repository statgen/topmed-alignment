package Topmed::Command::update;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['bamid|b=i', 'ID From topmed db of BAM to update'],
    ['jobid|j=s', 'Record the job id that processed the BAM'],
    ['state|s=s', 'Mark the bam as [requested|failed|completed|cancelled|submitted]'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($self->app->global_options->{help} or $opts->{bamid}) {
    $self->usage_error('BAM DB ID is required');
  }

  if ($opts->{state}) {
    unless (any {$opts->{state} eq $_} keys %BAM_STATUS) {
      $self->usage_error('Invalid state specificed');
    }
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
  my $bam = $db->resultset('Bamfile')->find($opts->{bamid});

  die "BAM [$opts->{bamid}] does not exist in the db" unless $bam;

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

  if ($opts->{jobid}) {
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
