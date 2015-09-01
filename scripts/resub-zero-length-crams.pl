#!/usr/bin/env perl

use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

my $db = Topmed::DB->new();

while (<STDIN>) {
  chomp;
  my $bam_rs = $db->resultset('Bamfile')->search({bamname => {like => $_ . '%'}});
  say "Unable to find a record for bam [$_]" unless $bam_rs->count;
  say "Found more than one record for bam [$_]" if $bam_rs->count > 1;
  if (my $bam = $bam_rs->first) {
    if ($bam->mapping->cluster eq 'csg') {
      my $cmd = sprintf $JOB_STATE_CMD_FORMAT{csg}, $bam->jobidmapping;
      chomp(my $state = capture(EXIT_ANY, $cmd));
      say $bam->bamid . ' => ' . $state;
    }
  }
}
