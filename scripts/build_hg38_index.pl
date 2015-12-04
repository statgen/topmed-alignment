#!/usr/bin/env perl

use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

my $index  = q{/net/topmed/working/hmkang/snps/153/data/topmed-dups-rels-153.index};
#my $index  = q{/net/topmed/working/build38/logs/failures/samples.txt};
my $schema = Topmed::DB->new();

for my $line (read_lines($index)) {
  chomp($line);
  my ($sample_id, $bamname_orig, $cramname, $center, $pi) = split(/\t/,$line);

  my $bam_db = $schema->resultset('Bamfile')->search([{bamname_orig => basename($bamname_orig)}, {bamname => basename($bamname_orig)}])->first();

  my $prefix = q{/net/topmed/incoming/topmed};
  if ($bam_db->run->center->centername eq 'broad' and $bam_db->run->dirname eq '2015jul03') {
    $prefix = '/nfs/turbo/topmed/incoming/topmed';
  }

  my $file = File::Spec->join($prefix, $bam_db->run->center->centername, $bam_db->run->dirname, $bam_db->bamname);
  #say join("\t", $bam_db->expt_sampleid, $file, 'foo', $bam_db->run->center->centername, $bam_db->piname);
  say join(",", $bam_db->expt_sampleid, $bamname_orig, $file, $bam_db->run->center->centername, $bam_db->studyname, $bam_db->piname);
}
