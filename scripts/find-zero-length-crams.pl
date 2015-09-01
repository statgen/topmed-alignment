#!/usr/bin/env perl

use Topmed::Base;
use Topmed::DB;

my @bams = ();
my $db = Topmed::DB->new();

while (<STDIN>) {
  chomp;
  my (@parts) = split(/\s+/);

  unless ($parts[6]) {
    (my $bamid = basename($parts[10])) =~ s/\.recal\.cram//g;
    say $bamid;
#   my $dir = dirname($parts[10]);
#   my $bam_list = qq{$dir/../bam.list};
#   run(qq{cat $bam_list});
#   (my $bamname = basename($parts[10])) =~ s/\.recal\.cram//g;
#   chomp(my $bamid = capture(qq{grep $bamname ../logs/align/* -l|xargs grep BAM_DB_ID|awk {'print \$2'}}));
#   push @bams, $bamid;
  }
}

#print Dumper \@bams, scalar @bams;
