package Topmed::Command::resubmit;

use Topmed -command;
use Topmed::Base qw(db);
use Topmed::Config;

sub opt_spec {
  return (
    ['bamid|b=i', 'BAM id to resubmit for processing'],
    ['jobid|j=i', 'Jobid to resubmit for processing'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($opts->{bamid} or $opts->{jobid}) {
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
  my $conf  = Topmed::Config->new();

  if ($opts->{bamid}) {
    $bamid = $opts->{bamid};

  } elsif ($opts->{jobid}) {
    my $db  = Topmed::DB->new();
    my $bam = $db->resultset('Bamfile')->search({jobidmapping => {like => $opts->{jobid} . '%'}});

    die "No matching BAM for job id $opts->{jobid}" unless $bam->count;
    die "Multiple BAMs have job id $opts->{jobid}" if $bam->count > 1;

    $bamid = $bam->first->bamid;
  }

  die "BAM ID undefined" unless defined $bamid;

  my $cache = $conf->cache();
  my $entry = $cache->entry($bamid);

  die "BAM ID [$bamid] does not exist in cache" unless $entry->exists;

  my $bam = $entry->thaw();
  delete $bam->{job_id};
  delete $bam->{clst};
  delete $bam->{delay};
  $bam->{status} = $BAM_STATUS{requested};

  $entry->freeze($bam);

  say "Reset BAM [$bamid] successfully" if $self->app->global_options->{verbose};
  print Dumper $bam if $self->app->global_options->{debug};
}

1;

__END__

=head1

Topmed::Command::resubmit - Resubmit a BAM for mapping.
