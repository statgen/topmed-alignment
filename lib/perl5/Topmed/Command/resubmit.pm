package Topmed::Command::resubmit;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

sub opt_spec {
  return (['bamid|b=i', 'BAM id to resubmit for processing'], ['jobid|j=i', 'Jobid to resubmit for processing'],);
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($self->app->global_options->{help} or ($opts->{bamid} or $opts->{jobid})) {
    $self->usage_error('bam id or job id are required');
  }

  if ($self->app->global_options->{help}) {
    say $self->app->usage->text;
    print $self->usage->text;
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $bamid = undef;
  my $db    = Topmed::DB->new();

  if ($opts->{bamid}) {
    $bamid = $opts->{bamid};

  } elsif ($opts->{jobid}) {
    my $bam = $db->resultset('Bamfile')->search({jobidmapping => {like => $opts->{jobid} . '%'}});

    die "No matching BAM for job id $opts->{jobid}" unless $bam->count;
    die "Multiple BAMs have job id $opts->{jobid}" if $bam->count > 1;

    $bamid = $bam->first->bamid;
  }

  my $bam = $db->resultset('Bamfile')->find($bamid);
  die "BAM ID [$bamid] does not exist in db" unless $bam;

  $bam->update(
    {
      jobidmapping => undef,
      datemapping  => $BAM_STATUS{requested},
    }
  );

  say "Reset BAM [$bamid] successfully" if $self->app->global_options->{verbose};
}

1;

__END__

=head1

Topmed::Command::resubmit - Resubmit a BAM for mapping.
