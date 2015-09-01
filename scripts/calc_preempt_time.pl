#!/usr/bin/env perl

use Topmed::Base;
use Topmed::Config;
use List::MoreUtils qw(minmax);

my %jobs = ();
my $total = 0;

while (<STDIN>) {
  chomp;
  my ($jobid, $time) = split(/\s/);
  my $hours = parse_time($time);
  $jobs{$jobid} += $hours;
  $total += $hours;
}

my ($min, $max) = minmax(values %jobs);
say "Average Hours: " . sprintf '%.2f', $total / scalar keys %jobs;
say "Max Hours: " . $max;
say "Total Hours: $total";

sub parse_time {
  my ($time) = @_;

  for my $regexp (@TIME_FORMAT_REGEXPS) {
    if ($time =~ $regexp) {
      return (($+{days} * 24) + $+{hours}) if $+{days} and $+{hours};
      return $+{hours} if $+{hours};
      return int($+{seconds} / 60 / 60) if $+{seconds};
    }
  }

  return 0;
}


