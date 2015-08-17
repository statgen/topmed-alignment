#!/usr/bin/env perl

use Topmed::Base;
use Topmed::Config;

my $total_days = 0;
my $total_hrs  = 0;
my @lines      = read_lines('/home/schelcj/allchrisjobs');
my $result_ref = {};

for my $line (@lines) {
  chomp $line;
  $line =~ s/\s+/|/g;
  my @parts = split(/\|/, $line);
  $result_ref->{$parts[0]} = $parts[-1];
}


for my $key (keys %{$result_ref}) {

  my $log = qq{../tmp/${key}ich.edu.txt};
  unless (-e $log) {
    say "$log does not exist";
  }

  for my $regexp (@TIME_REMAINING_FORMAT_REGEXPS) {
    if ($result_ref->{$key} =~ /$regexp/) {
      $total_days += $+{days}  // 0;
      $total_hrs  += $+{hours} // 0;
    }
  }
}

#my $total = (($total_days + int($total_hrs / 24)) * 24);
#my $total = $total_hrs / 24;

#say "Total Days: $total";
#print Dumper scalar keys %{$result_ref}, $total_hrs, $total_hrs / 24;
#print Dumper keys %{$result_ref};
