#!/usr/bin/env perl

use FindBin qw($Bin);
use Modern::Perl;
use Data::Dumper;
use File::Slurp::Tiny qw(read_lines);
use List::MoreUtils qw(any indexes);
use File::Basename;
use IPC::System::Simple qw(run);

my $align_status = q{/net/1000g/hmkang/etc/nowseq/topmed/topmed.latest.alignstatus};
my @results      = parse_align_status($align_status);

for my $result (@results) {
# my @indexes = indexes {$_->{state} =~ /QPLOT/} @{$result->{results}};
# if (@indexes) {
#   my $pos = $result->{results}->[$indexes[0]];
#   print Dumper \@indexes;
# }

# my @indexes = indexes {$_->{state} eq 'ALIGN_COMPLETE_NO_OK'} @{$result->{results}};
# if (@indexes) {
#   my $index = $result->{results}->[$indexes[0]];
#   my $dir   = $index->{result};
#   my $file  = $dir . '/' . basename($dir) . '.OK';

#   say("touch $file");
# }

# if (any {$_->{state} =~ /DUP_/} @{$result->{results}}) {
#   if (any {$_->{state} =~ 'ALIGN_COMPLETE'} @{$result->{results}}) {

#     for (@{$result->{results}}) {
#       run(qq{rm -rf $_->{result}}) if $_->{state} =~ /DUP/;
#     }
#   }
# }
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


