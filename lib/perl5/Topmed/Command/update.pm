package Topmed::Command::update;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['bamid|b=i', 'ID From topmed db of bam to update'],
    ['state|s=s', 'Mark the bam as [requested|failed|finished|cancelled|unknown]'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $conf  = Topmed::Config->new();
  my $cache = $conf->cache();

  unless ($opts->{bamid}) {
    $self->usage_error('BAM DB ID is required');
  }

  unless (all {exists $BAM_STATUS{$_}} keys %BAM_STATUS) {
    $self->usage_error('Invalid state specificed');
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
  $entry->freeze($bam);
}

1;

__END__

=head1

Topmed::Command::update - Update the status of a BAM
