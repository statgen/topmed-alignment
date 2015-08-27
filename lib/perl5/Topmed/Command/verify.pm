package Topmed::Command::verify;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;
use Topmed::BAM;

sub opt_spec {
  return (['cluster=s', 'Specifiy which cluster to test against [csg|flux]']);
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  unless ($opts->{cluster}) {
    $self->usage_error('Cluster is required');
  }

  unless ($opts->{cluster} =~ /csg|flux/) {
    $self->usage_error('Invalid cluster value. Acceptable values are csg or flux.');
  }

  if ($self->app->global_options->{help}) {
    say $self->usage->text;
    print $self->app->usage->text;
    exit;
  }
}


sub execute {
  my ($self, $opts, $args) = @_;

  my $db = Topmed::DB->new();

  for my $bam_rs ($db->resultset('Bamfile')->all()) {
    next unless $bam_rs->status == $BAM_STATUS{completed};

    my $bam = Topmed::BAM->new(
      cluster => $opts->{cluster},
      id      => $bam_rs->bamid,
      center  => $bam_rs->run->center->centername,
      rundir  => $bam_rs->run->dirname,
      name    => $bam_rs->bamname,
      pi      => $bam_rs->piname,
    );

    unless ($bam->is_complete) {
      say $bam_rs->status_line . ' Sample ID: ' . $bam->sample_id . ' Complete: NO';
      print Dumper $bam if $self->app->global_options->{debug};
    }
  }
}

1;

__END__

=head1

Topmed::Command::verify - Verify that completed bams
