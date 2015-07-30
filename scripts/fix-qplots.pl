#!/usr/bin/env perl

use Modern::Perl;
use Data::Dumper;
use File::Temp;
use File::Slurp::Tiny qw(read_lines write_file);
use File::Basename;
use List::MoreUtils qw(apply);
use Makefile::Parser;
use IPC::System::Simple qw(run);
use Path::Class;
use Topmed::DB;

my $db      = Topmed::DB->new();
my $status  = q{/net/1000g/hmkang/etc/nowseq/topmed/topmed.latest.alignstatus};
my @results = parse_align_status($status);

for my $result (@results) {
  my $bam = $db->resultset('Bamfile')->search({bamname => basename($result->{orig_bam})});
  unless ($bam->count == 1) {
    say "Found duplicate bam files in the database for $result->{orig_bam}";
    next;
  }

  my $bamid = $bam->first->bamid;

  for my $result (@{$result->{results}}) {
    if ($result->{state} eq 'ALIGN_QPLOT_PENDING') {
      my $makefile = sprintf '%s/Makefiles/align_%s.Makefile', $result->{result}, basename($result->{result});
      my $batch_script = create_batch_script($bamid, $result->{sampleid}, $result->{result}, $makefile);

      print Dumper $batch_script;

      # run('/usr/cluster/bin/sbatch', $batch_script);
    }
  }
}

sub parse_align_status {
  my $file = shift;

  my @results = ();
  for my $line (read_lines($file)) {
    chomp($line);
    my @parts = split(/\s/, $line);
    next unless $parts[3] =~ /QPLOT_PENDING/;

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

sub create_batch_script {
  my ($bamid, $sampleid, $result_dir, $makefile) = @_;

  my $temp = File::Temp->new(
    DIR    => q{/tmp/topmed/qplots},
    SUFFIX => '.sh',
    UNLINK => 0,
  );

  my $parser = Makefile::Parser->new();
  $parser->parse($makefile);

  for my $target ($parser->targets) {
    if ($target->name =~ /qplot\.done/) {
      my ($prereq) = $target->prereqs;
      $prereq =~ s/\.done$//g;

      my $parent   = Path::Class::File->new($prereq)->parent();
      my @commands = apply {$_ =~ s/\$\(\@D\)/$parent/g} apply {$_ =~ s/\$</$prereq/g} apply {$_ =~ s/^@//g} $target->commands;
      my $batch    = _batch_script($bamid, $sampleid, $result_dir, $makefile, $target->name, join("\n", @commands));

      write_file($temp->filename, $batch);
    }
  }

  return $temp->filename;
}

sub _batch_script {
  my ($bamid, $sampleid, $result_dir, $makefile, $target, $commands) = @_;

  return <<"EOF"
#!/bin/sh

#SBATCH --partition=topmed-incoming
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=schelcj\@umich.edu
#SBATCH --mem=8000
#SBATCH --time=12:00:00
#SBATCH --job-name=rerun_qplot

export PREFIX=/net/topmed/working/schelcj/align
export PATH=\$PREFIX/bin:\$PATH
export PERL_CARTON_PATH=\$PREFIX/local.csg
export PERL5LIB=\$PERL_CARTON_PATH/lib/perl5:\$PREFIX/lib/perl5:\$PERL5LIB

# Makefile: $makefile
# Target:   $target
#
### Begin: makefile parsed target
$commands
### End: makefile parsed target

if [ \$? -eq 0 ]; then
  topmed update --bamid $bamid --state completed
fi
EOF
}
