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

  my $conf  = Topmed::Config->new();
  my $cache = $conf->cache();

  unless ($opts->{cluster}) {
    $self->usage_error('Cluster environment is required');
  }

  unless ($opts->{cluster} =~ /csg|flux/) {
    $self->usage_error('Invalid cluster environment');
  }

  if ($opts->{center}) {
    my $entry   = $cache->entry('centers');
    my $centers = $entry->thaw();

    unless (exists $centers->{$opts->{center}}) {
      $self->usage_error('Invalid Center');
    }
  }

  if ($opts->{study}) {
    my $entry   = $cache->entry('studies');
    my $studies = $entry->thaw();

    unless (exists $studies->{$opts->{study}}) {
      $self->usage_error('Invalid Study');
    }
  }

  if ($opts->{pi}) {
    my $entry = $cache->entry('pis');
    my $pis   = $entry->thaw();

    unless (exists $pis->{$opts->{pi}}) {
      $self->usage_error('Invalid PI');
    }
  }

  if ($self->app->global_options->{help}) {
    say $self->app->usage->text;
    print $self->usage->text;
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
    my $host  = $BAM_HOST_PRIMARY;

    my $center_path = File::Spec->join($BAM_FILE_PREFIX{$clst}, $bam->{center});
    my $path        = File::Spec->join($center_path, $bam->{dir}, $bam->{name});

    if (-l $center_path) {
      my $file       = Path::Class->file(readlink($center_path));
      my @components = $file->components();
      $host          = $components[4];
    }

    next if $opts->{center} and lc($bam->{center}) ne lc($opts->{center});
    next if $opts->{study}  and lc($bam->{study}) ne lc($opts->{study});
    next if $opts->{pi}     and lc($bam->{pi}) ne lc($opts->{pi});

    unless (defined $bam->{status}) {
      say "$bamid has an undefined status!" if $self->app->global_options->{verbose};
      next;
    }

    if ($bam->{status} == $BAM_STATUS{requested}) {
      last if ++$jobs_submitted > $opts->{limit};

      say "Sumitting remapping job for $bam->{name}" if $self->app->global_options->{verbose};

      unless ($opts->{'dry_run'}) {
        my $delay = int(rand(120));
        my $cmd   = System::Command->new(
          ($JOB_CMDS{$clst}, $BATCH_SCRIPT), {
            env => {
              BAM_CENTER => $bam->{center},
              BAM_FILE   => $path,
              BAM_PI     => $bam->{pi},
              BAM_DB_ID  => $bamid,
              BAM_HOST   => $host,
              DELAY      => $delay,
            }
          }
        );

        my $output = q{};
        my $stdout = $cmd->stdout();
        while (<$stdout>) { $output .= $_; }

        if ($self->app->global_options->{debug}) {
          my $stderr = $cmd->stderr();
          while (<$stderr>) { print $_; }
        }

        $cmd->close();

        say "Output from $JOB_CMDS{$clst} was '$output'" if $self->app->global_options->{debug};

        if ($output =~ /$JOB_OUTPUT_REGEXP{$clst}/) {
          $bam->{job_id} = $+{jobid};
          say "Captured job id $bam->{job_id} from $JOB_CMDS{$clst} output" if $self->app->global_options->{debug};
        }

        $bam->{status} = $BAM_STATUS{submitted};
        $bam->{clst}   = $clst;
        $bam->{delay}  = $delay;
        $bam->{host}   = $host;

        print Dumper $bam if $self->app->global_options->{debug};
        $entry->freeze($bam);
      }

    }
  }
}

1;

__END__

=head1

Topmed::Command::launch - Launch a remapping job on the next available BAM
