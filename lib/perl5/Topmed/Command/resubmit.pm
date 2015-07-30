package Topmed::Command::resubmit;

use Topmed -command;
use Topmed::Base qw(db);
use Topmed::Config;

sub opt_spec {
  return (['bamid|b=i', 'BAM id to resubmit for processing'],);
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($opts->{bamid}) {
    $self->usage_error('BAM ID is required');
  }

  if ($self->app->global_options->{help}) {
    say $self->app->usage->text;
    print $self->usage->text;
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $conf  = Topmed::Config->new();
  my $cache = $conf->cache();
  my $entry = $cache->entry($opts->{bamid});

  die "BAM ID [$opts->{bamid}] does not exist in cache" unless $entry->exists;

  my $bam = $entry->thaw();
  delete $bam->{job_id};
  delete $bam->{clst};
  delete $bam->{delay};
  $bam->{status} = $BAM_STATUS{requested};

  $entry->freeze($bam);

  say "Reset BAM [$opts->{bamid}] successfully" if $self->app->global_options->{verbose};
  print Dumper $bam if $self->app->global_options->{debug};
}

1;

__END__

=head1

Topmed::Command::resubmit - Resubmit a BAM for mapping.
