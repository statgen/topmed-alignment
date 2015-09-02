package Topmed::Command::launch;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

sub opt_spec {
  return (
    ['cluster|c=s', 'Cluster environment [csg|flux]'],
    ['dry_run|n',   'Dry run; Do everything except submit the job'],
    ['limit|l=i',   'Limit number of jobs submitted'],
    ['study=s',     'Only map BAMs from a sepcific study'],
    ['center=s',    'Only map BAMs from a specific center'],
    ['pi=s',        'Only map BAMs from a specific PI'],
    ['bamid|b=i',   'Remap a specific BAM based on the db id (override studies, centers, and pis)'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  my $db = Topmed::DB->new();
  $self->{stash}->{db} = $db;

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

  if ($opts->{bamid}) {
    unless ($db->resultset('Bamfile')->search({bamid => $opts->{bamid}})->count()) {
      $self->usage_error('Invalid BAM ID');
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

  my $jobs   = 0;
  my $db     = $self->{stash}->{db};
  my $attrs  = {};
  my $search = {};

  if ($opts->{bamid}) {
    $search->{bamid} = $opts->{bamid};
  } else {
    if ($opts->{study}) {
      $search->{studyname} = $opts->{study};
    }

    if ($opts->{pi}) {
      $search->{piname} = $opts->{pi};
    }

    if ($opts->{center}) {
      $attrs = {join => {run => 'center'}};
      $search->{'center.centername'} = $opts->{center};
    }
  }

  if ($self->app->global_options->{debug}) {
    $Data::Dumper::Varname = 'SEARCH';
    print Dumper $search;

    $Data::Dumper::Varname = 'ATTRS';
    print Dumper $attrs;
  }

  for my $bam ($db->resultset('Bamfile')->search($search, $attrs)) {
    next if $bam->status >= $BAM_STATUS{submitted} and not $opts->{bamid};
    next unless $bam->has_arrived();
    last if $opts->{limit} and ++$jobs > $opts->{limit};

    my $clst        = $opts->{cluster};
    my $host        = $BAM_HOST_PRIMARY;
    my $center_path = File::Spec->join($BAM_FILE_PREFIX{$clst}, $bam->run->center->centername);
    my $path        = File::Spec->join($center_path, $bam->run->dirname, $bam->bamname);

    if (-l $center_path) {
      my $file       = Path::Class->file(readlink($center_path));
      my @components = $file->components();
      $host = $components[4];
    }

    say "Sumitting remapping job for " . $bam->bamname if $self->app->global_options->{verbose};

    my $delay   = int(rand(120));
    my $job_env = {
      env => {
        BAM_CENTER => $bam->run->center->centername,
        BAM_FILE   => $path,
        BAM_PI     => $bam->piname,
        BAM_DB_ID  => $bam->bamid,
        BAM_HOST   => $host,
        DELAY      => $delay,
      }
    };

    print Dumper $job_env if $self->app->global_options->{debug};

    unless ($opts->{'dry_run'}) {
      my $job_id = undef;
      my $output = q{};
      my $cmd    = System::Command->new(($JOB_CMDS{$clst}, $BATCH_SCRIPT, $JOB_NAME_OPT{$clst}, $bam->expt_sampleid), $job_env);

      print Dumper $cmd->cmdline() if $self->app->global_options->{debug};

      my $stdout = $cmd->stdout();
      while (<$stdout>) {$output .= $_;}

      if ($self->app->global_options->{debug}) {
        my $stderr = $cmd->stderr();
        while (<$stderr>) {print $_;}
      }

      $cmd->close();
      my $exit = $cmd->exit();

      if ($exit) {
        say "$JOB_CMDS{$clst} returned non-zero exit [$exit]";
        next;
      }

      say "Output from $JOB_CMDS{$clst} was '$output'" if $self->app->global_options->{debug};

      if ($output =~ /$JOB_OUTPUT_REGEXP{$clst}/) {
        $job_id = $+{jobid};
        say "Captured job id '$job_id' from $JOB_CMDS{$clst} output" if $self->app->global_options->{debug};
      }

      $bam->update(
        {
          datemapping  => $BAM_STATUS{submitted},
          jobidmapping => $job_id,
        }
      );

      my $job = $db->resultset('Mapping')->find_or_create({bam_id => $bam->bamid});

      $job->update(
        {
          run_id      => $bam->runid,
          center_id   => $bam->run->centerid,
          job_id      => $job_id,
          bam_host    => $host,
          status      => $BAM_STATUS{submitted},
          cluster     => $opts->{cluster},
          delay       => $delay,
          modified_at => DateTime->now(),
        }
      );
      say 'Updated mapping record ' . $job->id if $self->app->global_options->{debug};
    }
  }
}

1;

__END__

=head1

Topmed::Command::launch - Launch a remapping job on the next available BAM
