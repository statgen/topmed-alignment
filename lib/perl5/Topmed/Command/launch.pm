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
    ['dry_run|n',   'Dry run; Do everything except submit the job'],
    ['limit|l=i',   'Limit number of jobs submitted'],
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

  my $jobs_submitted = 0;
  my $conf           = Topmed::Config->new();
  my $cache          = $conf->cache();
  my $idx            = $cache->entry($BAM_CACHE_INDEX);

  unless ($idx->exists) {
    die 'No index of BAM IDs found!';
  }

  my $indexes = $idx->thaw();
  for my $bamid (keys %{$indexes}) {

    last if $jobs_submitted > $opts->{limit};

    my $clst  = $opts->{cluster};
    my $entry = $cache->entry($bamid);
    my $bam   = $entry->thaw();
    my $path  = File::Spec->join($BAM_FILE_PREFIX{$clst}, $bam->{center}, $bam->{dir}, $bam->{name});

    next if $opts->{center} and lc($bam->{center}) ne lc($opts->{center});
    next if $opts->{study}  and lc($bam->{study}) ne lc($opts->{study});
    next if $opts->{pi}     and lc($bam->{pi}) ne lc($opts->{pi});

    if ($bam->{status} == $BAM_STATUS{requested}) {
      unless ($opts->{'dry_run'}) {
        say "Sumitting remapping job for $bam->{name}" if $self->app->global_options->{verbose};

        print Dumper $bam if $self->app->global_options->{debug};

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
        $jobs_submitted++;
      }
    }
  }
}

1;

__END__

=head1

Topmed::Command::launch - Launch a remapping job on the next available BAM
