#!/usr/bin/env perl
#
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

my $db = Topmed::DB->new();

for my $bam ($db->resultset('Bamfile')->all()) {
  my $mapping = $db->resultset('Mapping')->find_or_create({bam_id => $bam->bamid});

  $mapping->update(
    {
      run_id    => $bam->runid,
      center_id => $bam->run->centerid,
      job_id    => $bam->jobidmapping,
      status    => $bam->status,
    }
  );

  say 'Updated mapping ' . $mapping->id() . ' for bam: ' . $bam->bamid;
}
