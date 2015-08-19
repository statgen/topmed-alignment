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
    $bam->update({datemapping => $BAM_STATUS{$opts->{state}}});
  }

  if ($opts->{jobid}) {
    $bam->update({jobidmapping => $opts->{jobid}});
  }
}

1;

__END__

=head1

Topmed::Command::update - Update the status of a BAM
