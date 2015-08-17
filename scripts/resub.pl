#!/usr/bin/env perl

use FindBin qw($Bin);
use lib (qq($Bin/../lib/perl5));

use List::MoreUtils qw(:all);
use File::Slurp qw(read_file);
use IPC::System::Simple qw(capture);

use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

die;

my $clst = $ARGV[0];
my $db   = Topmed::DB->new();

for my $bam ($db->resultset('Bamfile')->all()) {
  next if $bam->status != $BAM_STATUS{submitted};
  next if $bam->status != $BAM_STATUS{failed};     # FIXME

  if (defined $bam->jobidmapping) {
    given ($clst) {
      when (/csg/)  {_process_csg_jobs($bam->jobidmapping,  $bam->bamid)}
      when (/flux/) {_process_flux_jobs($bam->jobidmapping, $bam->bamid)}
    }
  }
}

sub _process_csg_jobs {
  my ($job_id, $bam_id) = @_;
  chomp(my $job_state = capture(qq(sacct -j $job_id -X -n -o state%7)));
  return if $job_state =~ /running|pending/i;
  say "bin/topmed resubmit -b $bam_id";
}

sub _process_flux_jobs {
  my ($job_id, $bam_id) = @_;
  my $rc = system(qq{checkjob -v $job_id 2>&1 > /dev/null && echo \$?});
  return unless $rc;
  say "bin/topmed resubmit -b $bam_id";
}
