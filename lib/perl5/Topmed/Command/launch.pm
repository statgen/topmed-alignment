package Topmed::Command::launch;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['cluster|c=s', 'Cluster environment [csg|flux]'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($self->app->global_options->{help}) {
    print $self->app->usage->text;
    exit;
  }

  unless ($opts->{cluster}) {
    $self->usage_error('Cluster environment is required');
  }

  unless ($opts->{cluster} =~ /csg|flux/) {
    $self->usage_error('Invalid cluster environment');
  }
}

sub execute {
  my ($self, $opts, $args) = @_;
  # my $path = File::Spec->join($BAM_FILE_PREFIX{$opts->{cluster}}, $center, $bam->dirname, $bam->bamname);

  my $conf = Topmed::Config->new();
  my $cache = $conf->cache();
  my $idx   = $cache->entry($BAM_CACHE_INDEX);

  unless ($idx->exists) {
    confess 'No index of BAM IDs found!';
  }

  my $indexes = $idx->thaw();
  for my $bamid (keys %{$indexes}) {
    print Dumper $bamid;
  }
}

1;

__END__

=head1

Topmed::Command::launch - Launch a remapping job on the next available BAM
