#!/usr/bin/env perl

use Modern::Perl;
use File::Temp;
use File::Slurp::Tiny qw(write_file);
use List::MoreUtils qw(apply);
use Makefile::Parser;
use Getopt::Long;

my $parser   = Makefile::Parser->new();
my $temp     = File::Temp->new(UNLINK => 0, DIR => q{/tmp/topmed/qplots});
my $makefile;
GetOptions('makefile=s' => \$makefile);

$parser->parse($makefile);

for my $target ($parser->targets) {
  if ($target->name =~ /qplot\.done/) {
    my @commands = grep {!/^mkdir/} apply {$_ =~ s/^@//g} $target->commands;
    my $batch = get_batch_script(join("\n", @commands));

    write_file($temp->filename, $batch);
    say 'wrote commands to ' . $temp->filename;
  }
}

sub get_batch_script {
  my $commands = shift;

  return <<"EOF"
#!/bin/sh
#
#SBATCH --partition=topmed-incoming
#SBATCH --mail-type=FAIL
#SBATCH --mail-user=schelcj\@umich.edu
#SBATCH --mem=4000
#SBATCH --time=06:00:00
#
$commands
EOF
}
