package Topmed::Command::launch;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['cluster|c=s', 'Cluster environment [csg|flux]'],
    ['study=s',     'Only map BAMs from a sepcific study'],
    ['center=s',    'Only map BAMs from a specific center'],
    ['pi=s',        'Only map BAMs from a specific PI'],
    ['dry_run|n',   'Dry run; Do everything except submit the job'],
    ['limit|l=i',   'Limit number of jobs submitted'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $conf = Topmed::Config->new();
  my $cache = $conf->cache();

  unless ($opts->{cluster}) {
    $self->usage_error('Cluster environment is required');
  }

  unless ($opts->{cluster} =~ /csg|flux/) {
    $self->usage_error('Invalid cluster environment');
  }

  if ($opts->{center}) {
    my $entry = $cache->entry('centers');
    my $centers = $entry->thaw();

    unless (exists $centers->{$opts->{center}}) {
      $self->usage_error('Invalid Center');
    }
  }

  if ($opts->{study}) {
    my $entry = $cache->entry('studies');
    my $studies = $entry->thaw();

    unless (exists $studies->{$opts->{study}}) {
      $self->usage_error('Invalid Study');
    }
  }

  if ($opts->{pi}) {
    my $entry = $cache->entry('pis');
    my $pis = $entry->thaw();

    unless (exists $pis->{$opts->{pi}}) {
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

  my $jobs_submitted = 0;
  my $conf           = Topmed::Config->new();
  my $cache          = $conf->cache();
  my $idx            = $cache->entry($BAM_CACHE_INDEX);

  unless ($idx->exists) {
    die 'No index of BAM IDs found!';
  }

  my $indexes = $idx->thaw();
  for my $bamid (keys %{$indexes}) {
    my $clst  = $opts->{cluster};
    my $entry = $cache->entry($bamid);
    my $bam   = $entry->thaw();
    my $path  = File::Spec->join($BAM_FILE_PREFIX{$clst}, $bam->{center}, $bam->{dir}, $bam->{name});

    next if $opts->{center} and lc($bam->{center}) ne lc($opts->{center});
    next if $opts->{study}  and lc($bam->{study}) ne lc($opts->{study});
    next if $opts->{pi}     and lc($bam->{pi}) ne lc($opts->{pi});
    next if $bam->{status} eq $BAM_STATUS{unknown};

    if ($bam->{status} == $BAM_STATUS{requested}) {
      last if ++$jobs_submitted > $opts->{limit};

      say "Sumitting remapping job for $bam->{name}" if $self->app->global_options->{verbose};
      print Dumper $bam if $self->app->global_options->{debug};

      unless ($opts->{'dry_run'}) {

        my $cmd = System::Command->new(
          ($JOB_CMDS{$clst}, $BATCH_SCRIPT), {
            env => {
              BAM_CENTER => $bam->{center},
              BAM_FILE   => $path,
              BAM_PI     => $bam->{pi},
              BAM_DB_ID  => $bamid,
            }
          }
        );

        my $stdout = $cmd->stdout();
        while (<$stdout>) {print $_ }
        $cmd->close();

        $bam->{status} = $BAM_STATUS{submitted};
        $entry->freeze($bam);
      }

    }
  }
}

1;

__END__

=head1

Topmed::Command::launch - Launch a remapping job on the next available BAM
