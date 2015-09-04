#!/usr/bin/env perl

use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

use List::MoreUtils qw(indexes);

my $clst    = $ARGV[0];
my $db      = Topmed::DB->new();
my $job_ref = {};

for my $line (read_lines('running.txt')) {
  chomp($line);
  my ($job_id, $bam_id) = split(/\s/, $line);
  push @{$job_ref->{$bam_id}}, $job_id;
}

for my $bam (keys %{$job_ref}) {
  next if $bam eq '';

  if (scalar @{$job_ref->{$bam}} > 1) {
    print Dumper $job_ref->{$bam};
    next;
  }

  my $bam_rs = $db->resultset('Bamfile')->find($bam);
  my $job_id = $job_ref->{$bam}->[0];

  next unless $bam_rs->status == $BAM_STATUS{completed};

  given ($clst) {
    when ('csg') {
      next unless $job_id =~ /^12/;
      print Dumper $bam . ' => ' . $job_ref->{$bam}->[0] . ' => ' . $bam_rs->status;
      #run(EXIT_ANY, "scancel $job_id");
      #run('topmed update -b ' . $bam_rs->bamid . ' -s failed');
    }
    when ('flux') {
      next unless $job_id =~ /^16/;
      print Dumper $bam . ' => ' . $job_ref->{$bam}->[0] . ' => ' . $bam_rs->status;
      #run(EXIT_ANY, "qdel $job_id");
      #run('topmed update -b ' . $bam_rs->bamid . ' -s failed');
    }
  }
}
