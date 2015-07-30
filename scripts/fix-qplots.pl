#!/usr/bin/env perl

use FindBin qw($Bin);
use Modern::Perl;
use Data::Dumper;
use File::Temp;
use File::Slurp::Tiny qw(read_lines write_file);
use File::Basename;
use List::MoreUtils qw(apply);
use Makefile::Parser;
use Path::Class;
use Topmed::DB;

my $db      = Topmed::DB->new();
my $status  = q{/net/1000g/hmkang/etc/nowseq/topmed/topmed.latest.alignstatus};
my @results = parse_align_status($status);
my $workdir = qq{$Bin/../../tmp/qplots};

for my $result (@results) {
  my $bam = $db->resultset('Bamfile')->search({bamname => basename($result->{orig_bam})});
  unless ($bam->count == 1) {
    say "Found duplicate bam files in the database for $result->{orig_bam}";
    next;
  }

  my $bamid = $bam->first->bamid;

  for my $align_result (@{$result->{results}}) {
    if ($align_result->{state} eq 'ALIGN_QPLOT_PENDING') {
      my $makefile = sprintf '%s/Makefiles/align_%s.Makefile', $align_result->{result}, basename($align_result->{result});

      create_batch_script($bamid, $result->{sampleid}, $align_result->{result}, $makefile);
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

  my $parser = Makefile::Parser->new();
  $parser->parse($makefile);

  my $clst = ($parser->var('OUT_DIR') =~ /\/dept\/csg/) ? 'flux' : 'csg';
  my $file = qq{$workdir/$clst-$sampleid.sh};

  for my $target ($parser->targets) {
    if ($target->name =~ /qplot\.done/) {
      my ($prereq) = $target->prereqs;
      $prereq =~ s/\.done$//g;

      unless (-e $prereq) {
        say "PREREQ does not exist! [$prereq]";
      }

      my $parent = Path::Class::File->new($target->name)->parent();
      my @commands = apply {$_ =~ s/\$\(\@D\)/$parent/g} apply {$_ =~ s/\$</$prereq/g} apply {$_ =~ s/^@//g} $target->commands;
      splice @commands, 3, 0, 'rc=$?';
      my $batch = _batch_script($bamid, $workdir, $result_dir, $makefile, $target->name, join("\n", @commands));

      write_file($file, $batch);
    }
  }

  return $file;
}

sub _batch_script {
  my ($bamid, $workdir, $result_dir, $makefile, $target, $commands) = @_;

  return <<"EOF"
#!/bin/sh

#SBATCH --ignore-pbs
#SBATCH --partition=topmed-incoming
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=schelcj\@umich.edu
#SBATCH --mem=8000
#SBATCH --time=12:00:00
#SBATCH --job-name=rerun_qplot
#SBATCH --workdir=/net/topmed$workdir
#
#PBS -l procs=1,walltime=12:00:00,pmem=8gb
#PBS -m a
#PBS -d /dept/csg/topmed$workdir
#PBS -M schelcj\@umich.edu
#PBS -q flux
#PBS -l qos=flux
#PBS -A goncalo_flux
#PBS -V
#PBS -j oe

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

case \$rc in
  0)
    topmed update --verbose --bamid $bamid --state completed
    ;;
  1)
    topmed update --verbose --bamid $bamid --state failed
    ;;
esac

exit \$rc
EOF
}
