package Topmed::Command::detect;

use Topmed -command;
use Topmed::Base qw(db);
use Topmed::Config qw(:all);

sub opt_spec {
  return (['verbose|v', 'Verbose output'],);
}

sub execute {
  my ($self, $opts, $args) = @_;
  my $db = Topmed::DB->new();

  # TODO
  #   * get this info - CENTER,DIRNAME,FULLPATHBAMID,BAMNAME,STUDYNAME,PINAME,BAMSIZE,DATEMAPPING
  #
  #   so terry added an export function to his code to output a csv with the
  #   above format. i guess i'll just have to parse that file, weee.

  my $cmd = System::Command->new($TOPMED_EXPORT_CMD, 'export');
  my $csv = Class::CSV->parse(
    filehandle => $cmd->stdout(),
    fields     => \@TOPMED_EXPORT_FIELDS,
  );

  my @lines = @{$csv->lines()};
  shift @lines; # XXX - remove the header row

  for my $line (@lines) {
    print Dumper $line;
  }

  $cmd->close();
}

1;

__END__

=head1

Topmed::Command::detect - Detect new BAM files to process
