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

  if ($self->app->global_options->{help}) {
    say $self->app->usage->text();
    print $self->usage->text();
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $db = Topmed::DB->new();
  my %r_bam_status = reverse %BAM_STATUS;

  if ($opts->{state}) {
    for my $bam ($db->resultset('Bamfile')->all()) {
      if ($bam->status == $BAM_STATUS{$opts->{state}}) {
        printf "ID: %-8s %-30s center: %-10s study: %-10s PI: %-10s\n", $bam->bamid, $bam->bamname, $bam->run->center->centername, $bam->studyname, $bam->piname;
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
    printf "ID: %-8s %-30s center: %-10s study: %-10s PI: %-10s Status: %s\n", $bam->bamid, $bam->bamname, $bam->run->center->centername, $bam->studyname, $bam->piname, $r_bam_status{$bam->status};
  }

  if ($opts->{jobid}) {
  my $bam   = $db->resultset('Bamfile')->search({jobidmapping => {like => $opts->{jobid} . '%'}})->first();
    printf "ID: %-8s %-30s center: %-10s study: %-10s PI: %-10s Status: %s\n", $bam->bamid, $bam->bamname, $bam->run->center->centername, $bam->studyname, $bam->piname, $r_bam_status{$bam->status};
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
}

1;

__END__

=head1

Topmed::Command::show - View info about BAM files in the database
