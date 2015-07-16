package Topmed::Command::launch;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

sub opt_spec {
  return (
    ['cluster|c=s', 'Cluster environment [csg|flux]'],
    ['study=s',     'Only map BAMs from a sepcific study'],
    ['center=s',    'Only map BAMs from a specific center'],
    ['pi=s',        'Only map BAMs from a specific PI'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $db = Topmed::DB->new();

  unless ($opts->{cluster}) {
    $self->usage_error('Cluster environment is required');
  }

  unless ($opts->{cluster} =~ /csg|flux/) {
    $self->usage_error('Invalid cluster environment');
  }

  if ($opts->{center}) {
    unless ($db->resultset('Center')->search({centername => $opts->{center}})->count()) {
      $self->usage_error('Invalid Center');
    }
  }

  if ($opts->{study}) {
    unless ($db->resultset('Bamfile')->search({studyname => $opts->{study}})->count()) {
      $self->usage_error('Invalid Study');
    }
  }

  if ($opts->{pi}) {
    unless ($db->resultset('Bamfile')->search({piname => $opts->{pi}})->count()) {
      $self->usage_error('Invalid PI');
    }
  }

  if ($self->app->global_options->{help}) {
    print $self->app->usage->text;
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $conf  = Topmed::Config->new();
  my $cache = $conf->cache();
  my $idx   = $cache->entry($BAM_CACHE_INDEX);

  unless ($idx->exists) {
    confess 'No index of BAM IDs found!';
  }

  my $indexes = $idx->thaw();
  for my $bamid (keys %{$indexes}) {
    my $clst  = $opts->{cluster};
    my $entry = $cache->entry($bamid);
    my $bam   = $entry->thaw();
    my $path  = File::Spec->join($BAM_FILE_PREFIX{$clst}, $bam->{center}, $bam->{dir}, $bam->{name});

    next if $opts->{center} and $bam->{center} ne $opts->{center};
    next if $opts->{study}  and $bam->{study} ne $opts->{study};
    next if $opts->{pi}     and $bam->{pi} ne $opts->{pi};

    print Dumper $bam;

=cut
    if ($bam->{status} eq 'requested') {
      my $cmd   = System::Command->new(
        ($JOB_CMDS{$clst}, $BATCH_SCRIPT),
        {
          env => {
            BAM_CENTER => $bam->{center},
            BAM_FILE   => $path,
            BAM_PI     => $bam->{pi},
          }
        }
      );

      my $stdout = $cmd->stdout();
      while (<$stdout>) { print $_ }
      $cmd->close();
    }
=cut

    $bam->{status} = $BAM_STATUS_SUBMITTED;
    $entry->freeze($bam);
  }
}

1;

__END__

=head1

Topmed::Command::launch - Launch a remapping job on the next available BAM
