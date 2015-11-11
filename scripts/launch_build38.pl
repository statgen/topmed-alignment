#!/usr/bin/env perl

use FindBin qw($Bin);
use Modern::Perl;
use Data::Dumper;
use File::Slurp::Tiny qw(read_lines);
use System::Command;
use Getopt::Long;

GetOptions(
  'samples=s' => \my $samples,
) or die;

my $script  = qq{$Bin/../batch.d/build38.sh};

for (read_lines($samples, chomp => 1)) {
  my ($sample_id, $bam, $cram, $center, $pi) = split(/\t/);

  $bam =~ s#^/net/topmed/incoming/topmed/broad/2015jul03#/nfs/turbo/topmed/incoming/broad/2015jul03#;
  $bam =~ s#^/net#/dept/csg#;

  my $job_name = qq{build38-$sample_id};
  my $job_env = {
    BAM_FILE   => $bam,
    BAM_CENTER => $center,
    BAM_PI     => $pi,
    BAM_HOST   => 'topmed',
    BAM_DB_ID  => 42,
    DELAY      => int(rand(120)),
  };

  my @cli = ('qsub', '-N', $job_name, $script);
  my $cmd = System::Command->new(@cli, {env => $job_env});

  my $stdout = $cmd->stdout();
  while (<$stdout>) {print $_;}

  my $stderr = $cmd->stderr();
  while (<$stderr>) {print $_;}

  $cmd->close();
}

