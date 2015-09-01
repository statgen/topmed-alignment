package Topmed::Command::resubmit;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

sub opt_spec {
  return (
    ['dry_run',   'Do not actually do anything'],
    ['bamid|b=i', 'BAM id to resubmit for processing'],
    ['jobid|j=i', 'Jobid to resubmit for processing'],
    ['failed',    'Resubmit any failed jobs'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($self->app->global_options->{help}) {
    say $self->app->usage->text;
    print $self->usage->text;
    exit;
  }

  $self->{stash}->{db} = Topmed::DB->new();
}

sub execute {
  my ($self, $opts, $args) = @_;

  if ($opts->{bamid}) {
    $self->update_bam($opts, $opts->{bamid});

  } elsif ($opts->{jobid}) {
    my $bam = $self->{stash}->{db}->resultset('Bamfile')->search({jobidmapping => {like => $opts->{jobid} . '%'}});

    die "No matching BAM for job id $opts->{jobid}" unless $bam->count;
    die "Multiple BAMs have job id $opts->{jobid}" if $bam->count > 1;

    $self->update_bam($opts, $bam->first->bamid);

  } elsif ($opts->{failed}) {
    for my $bam ($self->{stash}->{db}->resultset('Bamfile')->search({datemapping => $BAM_STATUS{failed}})) {
      $self->update_bam($opts, $bam->bamid);
    }
  }
}

sub update_bam {
  my ($self, $opts, $bam_id) = @_;

  my $bam = $self->{stash}->{db}->resultset('Bamfile')->find($bam_id);
  die "BAM ID [$bam_id] does not exist in db" unless $bam;

  unless ($opts->{dry_run}) {
    $bam->update(
      {
        jobidmapping => undef,
        datemapping  => $BAM_STATUS{requested},
      }
    );

    $bam->mapping->update(
      {
        job_id      => undef,
        cluster     => undef,
        delay       => undef,
        status      => $BAM_STATUS{requested},
        modified_at => DateTime->now(),
      }
    );
  }

  say "Reset BAM [$bam_id] successfully" if $self->app->global_options->{verbose};

  return;
}

1;

__END__

=head1

Topmed::Command::resubmit - Resubmit a BAM for mapping.
