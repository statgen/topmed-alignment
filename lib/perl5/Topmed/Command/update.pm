package Topmed::Command::update;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['bamid|b=i', 'ID From topmed db of bam to update'],
    ['completed', 'mark the bam file finished'],
    ['failed',    'mark the bam as failed'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $conf  = Topmed::Config->new();
  my $cache = $conf->cache();

  unless ($opts->{bamid}) {
    $self->usage_error('BAM DB ID is required');
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

  if ($opts->{failed}) {
    $bam->{status} = $BAM_STATUS{failed};

  } elsif ($opts->{completed}) {
    $bam->{status} = $BAM_STATUS{completed};

  }

  $entry->freeze($bam);
}

1;

__END__

=head1

Topmed::Command::update - Update the status of a BAM
