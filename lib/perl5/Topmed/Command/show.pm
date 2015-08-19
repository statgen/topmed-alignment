package Topmed::Command::show;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

sub opt_spec {
  return (
    ['state|s=s', 'Mark the bam as [requested|failed|completed|cancelled]'],
    ['undef|u',   'Show BAMs with undefined state'],
    ['bamid|b=i', 'BAM entry'],
    ['jobid|j=i', 'BAM entry for job id'],
    ['stale',     'Show BAMs that are marked submitted but not running'],
    ['cluster=s', 'Which cluster are we testing for the job state [csg|flux]'],
    ['centers',   'available centers'],
    ['studies',   'available studies'],
    ['pis',       'available PIs'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($opts->{state} and none {$opts->{state} eq $_} keys %BAM_STATUS) {
    $self->usage_error('Invalid state specificed');
  }

  if ($opts->{stale} and not $opts->{cluster}) {
    $self->usage_error('cluster is required to test for stale jobs');
  } elsif ($opts->{stale} and not exists $JOB_STATE_CMD_FORMAT{$opts->{cluster}}) {
    $self->usage_error('invalid cluster selection');
  }


  if ($self->app->global_options->{help}) {
    say $self->app->usage->text();
    print $self->usage->text();
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $db = Topmed::DB->new();

  if ($opts->{state}) {
    for my $bam ($db->resultset('Bamfile')->all()) {
      if ($bam->status == $BAM_STATUS{$opts->{state}}) {
        say $bam->status_line;
        print Dumper $bam if $self->app->global_options->{'debug'};
      }
    }
  }

  if ($opts->{undef}) {
    for my $bam ($db->resultset('Bamfile')->search({datemapping => undef})) {
      say 'BAM (' . $bam->bamid . ') has an undefined state' if $self->app->global_options->{'verbose'};
      print Dumper $bam if $self->app->global_options->{'debug'};
    }
  }

  if ($opts->{bamid}) {
    my $bam = $db->resultset('Bamfile')->find($opts->{bamid});
    say $bam->status_line;
  }

  if ($opts->{jobid}) {
    my $bam   = $db->resultset('Bamfile')->search({jobidmapping => {like => $opts->{jobid} . '%'}})->first();

    unless ($bam) {
      say "No match BAM for jobid $opts->{jobid}";
      next
    }

    say $bam->status_line;
  }

  if ($opts->{centers}) {
    for my $center ($db->resultset('Center')->all()) {
      say $center->centername;
    }
  }

  if ($opts->{studies}) {
    for my $study ($db->resultset('Bamfile')->search({}, {columns => ['studyname'], distinct => 1})) {
      say $study->studyname;
    }
  }

  if ($opts->{pis}) {
    for my $pi ($db->resultset('Bamfile')->search({}, {columns => ['piname'], distinct => 1})) {
      say $pi->piname;
    }
  }

  if ($opts->{stale}) {
    for my $bam ($db->resultset('Bamfile')->search({datemapping => $BAM_STATUS{submitted}})) {
      next unless $bam->mapping->cluster eq $opts->{cluster};

      (my $job_id = $bam->jobidmapping) =~ s/\.nyx$//g;

      my $cmd = sprintf $JOB_STATE_CMD_FORMAT{$opts->{cluster}}, $job_id;

      say "Testing for job state with command '$cmd'" if $self->app->global_options->{verbose};
      chomp(my $state = capture(EXIT_ANY, $cmd));

      say "Job state was '$state'" if $self->app->global_options->{debug};
      next if $state eq '';

      unless ($state =~ /running|pending|0/i) {
        say $bam->status_line . " JobId: $job_id State: $state";
      }
    }
  }
}

1;

__END__

=head1

Topmed::Command::show - View info about BAM files in the database
