#!/usr/bin/env perl

use Modern::Perl;
use Data::Dumper;
use List::MoreUtils qw(:all);
use File::Slurp qw(read_file);
use IPC::System::Simple qw(capture run);
use Topmed::Config;
use Topmed::DB;

my $db    = Topmed::DB->new();
my $conf  = Topmed::Config->new();
my $cache = $conf->cache();
my $index = $cache->entry($BAM_CACHE_INDEX)->thaw();

for my $id (keys %{$index}) {
  my $bam = $cache->entry($id)->thaw();
  next unless $bam->{status} == $BAM_STATUS{submitted};

  if (exists $bam->{clst} and exists $bam->{job_id}) {
    next if $bam->{job_id} =~ /nyx/;
    chomp(my $job_state = capture(qq(sacct -j $bam->{job_id} -X -n -o state%7)));

    #next if $job_state =~ /running/i;

    #print Dumper $bam, $job_state;
    say "JOB: $bam->{job_id} STATE: $job_state";
  }
}

__END__
my @jobs = apply {chomp $_} capture(q{squeue -u schelcj -n align-topmed -h -o %i});
my @subs = apply {chomp $_} capture(q(awk {'print $2'} ../tmp/submitted.txt));
for my $sub (@subs) {
  my $bam       = $db->resultset('Bamfile')->find($sub);
  my $bam_cache = $cache->entry($sub)->thaw();

  if (exists $bam_cache->{clst} and exists $bam_cache->{job_id}) {
    next if $bam_cache->{job_id} =~ /nyx/;
    my $job_state = capture(qq(sacct -j $bam_cache->{job_id} -X -n -o state%7));

    unless ($job_state =~ /RUNNING/) {
    }

    if ($job_state =~ /CANCEL/) {
      say "bin/topmed resubmit -b $sub -v ";
    }
  }
}
