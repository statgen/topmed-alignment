#!/usr/bin/env perl

use FindBin qw($Bin);
use Modern::Perl;
use Data::Dumper;
use File::Slurp::Tiny qw(read_lines);
use List::MoreUtils qw(any);

my $align_status = q{/net/1000g/hmkang/etc/nowseq/topmed/topmed.latest.alignstatus};
my @results      = parse_align_status($align_status);

for my $result (@results) {
  if (any {$_->{state} =~ /DUP_/} @{$result->{results}}) {
    if (any {$_->{state} eq 'ALIGN_COMPLETE'} @{$result->{results}}) {
      print Dumper $result;
    }
  }
}

sub parse_align_status {
  my $file = shift;

  my @results = ();
  for my $line (read_lines($file)) {
    chomp($line);
    my @parts = split(/\s/, $line);

    my $result_ref = {
      sampleid => $parts[0],
      orig_bam => $parts[1],
      results  => [],
    };

    if ($parts[2] =~ /\,/) {
      my @results = split(/,/, $parts[2]);
      my @states  = split(/,/, $parts[3]);

      for (0 .. $#results) {
        push @{$result_ref->{results}}, {result => $results[$_], state => $states[$_]};
      }
    } else {
      push @{$result_ref->{results}}, {result => $parts[2], state => $parts[3]};
    }

    push @results, $result_ref;
  }

  return @results;
}


