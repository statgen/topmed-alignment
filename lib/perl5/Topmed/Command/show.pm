package Topmed::Command::show;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['state|s=s', 'Mark the bam as [requested|failed|completed|cancelled|unknown]'],
    ['dump',      'Dump the cache to STDOUT'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($opts->{state} and none {$opts->{state} eq $_} keys %BAM_STATUS) {
    $self->usage_error('Invalid state specificed');
  }

  if ($self->app->global_options->{help}) {
    say $self->app->usage->text();
    print $self->usage->text();
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $conf  = Topmed::Config->new();
  $self->{stash}->{cache} = $conf->cache();

  if ($opts->{state}) {
    $self->show_state($opts->{state});
  }

  if ($opts->{dump}) {
    $self->dump_cache();
  }
}

sub show_state {
  my ($self, $state) = @_;

  my $cache  = $self->{stash}->{cache};
  my $entry  = $cache->entry($BAM_CACHE_INDEX);
  my $bamids = $entry->thaw();

  for my $bamid (keys %{$bamids}) {
    my $bam_entry = $cache->entry($bamid);

    unless ($bam_entry->exists()) {
      say "BAM ($bamid) listed in index but has no cache entry" if $self->app->global_options->('debug');
      next;
    }

    my $bam = $bam_entry->thaw();

    unless (defined $bam->{status}) {
      say "BAM ($bamid) has an undefined state" if $self->app->global_options->{'debug'};
      next;
    }

    if ($bam->{status} eq $BAM_STATUS{unknown}) {
      if ($bam->{status} eq $BAM_STATUS{$state}) {
        printf "%-8s: %-30s center: %-10s study: %-10s PI: %-10s\n", $bam->{id}, $bam->{name}, $bam->{center}, $bam->{study}, $bam->{pi};
        print Dumper $bam if $self->app->global_options->{'debug'};
      }
    } else {
      if ($bam->{status} == $BAM_STATUS{$state}) {
        printf "%-8s: %-30s center: %-10s study: %-10s PI: %-10s\n", $bam->{id}, $bam->{name}, $bam->{center}, $bam->{study}, $bam->{pi};
        print Dumper $bam if $self->app->global_options->{'debug'};
      }
    }
  }

  return;
}

sub dump_cache {
  my ($self) = @_;

  my $cache = $self->{stash}->{cache};
  my $entry = $cache->entry($BAM_CACHE_INDEX);
  my $index = $entry->thaw();

  die 'Unable to locate BAM cache index entry' unless $entry->exists();

  $Data::Dumper::Varname = 'BAM_INDEX';
  print Dumper $index;

  for my $id (keys %{$index}) {
    my $entry = $cache->entry($id);

    $Data::Dumper::Varname = 'BAM_' . $id;
    print Dumper $entry->thaw();
  }

  return;
}

1;

__END__

=head1

Topmed::Command::show - View info about BAM files in the cache
