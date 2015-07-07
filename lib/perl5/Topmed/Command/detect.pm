package Topmed::Command::detect;

use Topmed -command;
use Topmed::Base qw(db);

sub opt_spec {
  return (
    ['verbose|v', 'Verbose output'],
  );
}

sub execute {
  my ($self, $opts, $args) = @_;
  my $db = Topmed::DB->new();

}

1;

__END__

=head1

Topmed::Command::detect - Detect new BAM files to process
