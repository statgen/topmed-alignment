#!/usr/bin/env perl

use FindBin qw($Bin);
use Modern::Perl;
use Data::Dumper;
use File::Slurp::Tiny qw(read_lines);
use System::Command;

my $script  = qq{$Bin/../batch.d/build38.sh};
my $samples = q{/net/topmed/working/hmkang/snps/153/data/topmed-dups-rels-153.index};

for (read_lines($samples, chomp => 1)) {
  my ($sample_id, $bam, $cram, $center, $pi) = split(/\t/);

  my $job_name = qq{build38-$sample_id};
  my $job_env = {
    BAM_FILE   => $bam,
    BAM_CENTER => $center,
    BAM_PI     => $pi,
    BAM_HOST   => 'topmed',
    BAM_DB_ID  => 42,
    DELAY      => int(rand(120)),
  };

  my @cli = ('sbatch', '-J', $job_name, $script);
  my $cmd = System::Command->new(@cli, $job_env);
  print Dumper $cmd->cmdline();

  my $stdout = $cmd->stdout();
  while (<$stdout>) {print $_;}

  my $stderr = $cmd->stderr();
  while (<$stderr>) {print $_;}

  $cmd->close();
}

