package Topmed::Command::verify;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;
use Topmed::BAM;

sub opt_spec {
  return (
    ['cluster=s',  'Specifiy which cluster to test against [csg|flux]'],
    ['complete',   'Show complete CRAMs'],
    ['incomplete', 'Show incomplete CRAMs'],
    ['parsable',   'Output results in csv format'],
  );
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

  my $fields = [
    qw(
      bam_id
      center
      study
      pi
      sample_id
      bam
      cram
      crai
      )
  ];

  my $csv = Class::CSV->new(fields => $fields);
  my $db = Topmed::DB->new();

  if ($opts->{parsable}) {
    $csv->add_line({map {$_ => $_} @{$fields}});
  }

  for my $bam_rs ($db->resultset('Bamfile')->all()) {
    next unless $bam_rs->status == $BAM_STATUS{completed};

    my $line_ref = undef;
    my $bam      = Topmed::BAM->new(
      cluster => $opts->{cluster},
      id      => $bam_rs->bamid,
      center  => $bam_rs->run->center->centername,
      rundir  => $bam_rs->run->dirname,
      name    => $bam_rs->bamname,
      pi      => $bam_rs->piname,
    );

    if ($opts->{incomplete}) {
      unless ($bam->is_complete) {
        $line_ref = {
          bam_id    => $bam_rs->id,
          center    => $bam_rs->run->center->centername,
          study     => $bam_rs->studyname,
          pi        => $bam_rs->piname,
          sample_id => $bam->sample_id,
          bam       => $bam->bam,
          cram      => $bam->cram,
          crai      => $bam->crai,
        };

        say $bam_rs->status_line . ' Sample ID: ' . $bam->sample_id . ' Complete: NO' unless $opts->{parsable};
        print Dumper $bam if $self->app->global_options->{debug};
      }
    } elsif ($opts->{complete}) {
      if ($bam->is_complete) {
        $line_ref = {
          bam_id    => $bam_rs->id,
          center    => $bam_rs->run->center->centername,
          study     => $bam_rs->studyname,
          pi        => $bam_rs->piname,
          sample_id => $bam->sample_id,
          bam       => $bam->bam,
          cram      => $bam->cram,
          crai      => $bam->crai,
        };

        say $bam_rs->status_line . ' Sample ID: ' . $bam->sample_id . ' Complete: YES' unless $opts->{parsable};
        print Dumper $bam if $self->app->global_options->{debug};
      }
    }

    if (defined $line_ref) {
      $csv->add_line($line_ref);
    }
  }

  $csv->print if $opts->{parsable};
}

1;

__END__

=head1

Topmed::Command::verify - Verify that completed bams
