#!/usr/bin/env perl
#
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

my $db = Topmed::DB->new();

for my $bam ($db->resultset('Bamfile')->all()) {
  my $mapping = $db->resultset('Mapping')->find_or_create({bam_id => $bam->bamid});
  my $cluster = undef;

  if (not defined $bam->jobidmapping) {
    $cluster = undef;
  } elsif ($bam->jobidmapping =~ /nyx/) {
    $cluster = 'flux';
  } elsif ($bam->jobidmapping < 16510425) {
    $cluster = 'csg';
  } elsif ($bam->jobidmapping > 16510425) {
    $cluster = 'flux';
  }

  $mapping->update(
    {
      run_id    => $bam->runid,
      center_id => $bam->run->centerid,
      job_id    => $bam->jobidmapping,
      status    => $bam->status,
      cluster   => $cluster,
    }
  );

  say 'Updated mapping ' . $mapping->id() . ' for bam: ' . $bam->bamid;
}
