package Topmed::Command::detect;

use Topmed -command;
use Topmed::Base;

sub opt_spec {
  return (
    ['verbose|v', 'Verbose output'],
  );
}

sub execute {
  my ($self, $opts, $args) = @_;
}

1;

__END__

=head1

Topmed::Command::detect - Detect new BAM files to process
