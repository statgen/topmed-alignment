#!/usr/bin/env perl

use Topmed::Base;
use Topmed::DB;
use List::MoreUtils qw(indexes);

my $jobs = {};
my $db   = Topmed::DB->new();

for my $map ($db->resultset('Mapping')->all()) {
  next unless $map->job_id;
  (my $job_id = $map->job_id) =~ s/\.nyx.*$//g;
  push @{$jobs->{$job_id}}, $map->bam_id;
}

for my $job_id (keys %{$jobs}) {
  if (scalar @{$jobs->{$job_id}} > 1) {
    print Dumper $job_id, $jobs->{$job_id};
  }
}
