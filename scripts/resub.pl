#!/usr/bin/env perl

use Modern::Perl;
use Data::Dumper;
use List::MoreUtils qw(:all);
use File::Slurp qw(read_file);
use IPC::System::Simple qw(capture);
use Topmed::Config;

my $clst  = $ARGV[0];
my $conf  = Topmed::Config->new();
my $db    = Topmed::DB->new();

=cut
my $cache = $conf->cache();
my $index = $cache->entry($BAM_CACHE_INDEX)->thaw();

for my $id (keys %{$index}) {
  my $bam = $cache->entry($id)->thaw();
  next unless $bam->{status} == $BAM_STATUS{submitted} or $bam->{status} == $BAM_STATUS{failed};

  if (exists $bam->{clst} and exists $bam->{job_id}) {
    given ($clst) {
      when (/csg/) {_process_csg_jobs($bam->{job_id}, $id)}
      when (/flux/) {_process_flux_jobs($bam->{job_id}, $id)}
    }
  }
}
=cut

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
