package Test::Topmed::BAM;

use base qw(Test::Class);
use Test::Most;

use Topmed::Config;
use Topmed::BAM;

sub class {
  return q{Topmed::BAM};
}

sub startup : Test(startup) {
  my ($test) = @_;
  $test->{fixtures} = {
    cluster      => 'csg',
    bam_path     => qq{$BAM_FILE_PREFIX{csg}/illumina/2015may27.remainder/LP6008062-DNA_F07.hg19.bam},
    results_path => qq{$CLUSTER_PREFIX{csg}/topmed/$BAM_RESULTS_DIR/illumina/Barnes/LP6008062-DNA_F07},
    cram_path    => qq{$CLUSTER_PREFIX{csg}/topmed/$BAM_RESULTS_DIR/illumina/Barnes/LP6008062-DNA_F07/bams/LP6008062-DNA_F07.recal.cram},
    crai_path    => qq{$CLUSTER_PREFIX{csg}/topmed/$BAM_RESULTS_DIR/illumina/Barnes/LP6008062-DNA_F07/bams/LP6008062-DNA_F07.recal.cram.crai},
    pi           => q{Barnes},
    sample_id    => q{LP6008062-DNA_F07},
    id           => q{2758},
    host         => q{topmed},
    center       => q{illumina},
    rundir       => q{2015may27.remainder},
    name         => q{LP6008062-DNA_F07.hg19.bam},
  };
}

sub setup : Test(setup => 1) {
  my ($test) = @_;

  my $fixtures = $test->{fixtures};
  my $file     = Path::Class->file($fixtures->{bam_path});
  my @comps    = $file->components;

  $test->{bam} = $test->class->new(
    cluster   => $fixtures->{cluster},
    id        => $fixtures->{id},
    sample_id => $fixtures->{sample_id},
    center    => $fixtures->{center},
    rundir    => $fixtures->{rundir},
    name      => $fixtures->{name},
    pi        => $fixtures->{pi},
  );

  isa_ok($test->{bam}, $test->class);
}

sub test_bam_path : Test(1) {
  my ($test) = @_;

  my $bam      = $test->{bam};
  my $fixtures = $test->{fixtures};

  # diag($bam->bam);
  is($bam->bam, $fixtures->{bam_path}, 'bam path matches');
}

sub test_results_path : Test(1) {
  my ($test) = @_;

  my $bam      = $test->{bam};
  my $fixtures = $test->{fixtures};

  # diag($bam->results_path);
  is($bam->results_path, $fixtures->{results_path}, 'results path matches');
}

sub test_host : Test(1) {
  my ($test) = @_;

  my $bam      = $test->{bam};
  my $fixtures = $test->{fixtures};

  # diag($bam->host);
  is($bam->host, $fixtures->{host}, 'host matches');
}

sub test_cram : Test(1) {
  my ($test) = @_;

  my $bam      = $test->{bam};
  my $fixtures = $test->{fixtures};

  # diag($bam->cram);
  is($bam->cram, $fixtures->{cram_path}, 'cram path matches');
}

sub test_crai : Test(1) {
  my ($test) = @_;

  my $bam      = $test->{bam};
  my $fixtures = $test->{fixtures};

  # diag($bam->crai);
  is($bam->crai, $fixtures->{crai_path}, 'cram path matches');
}

sub test_is_complete : Test(1) {
  my ($test) = @_;

  my $bam = $test->{bam};
  ok($bam->is_complete, 'BAM is complete');
}

1;
