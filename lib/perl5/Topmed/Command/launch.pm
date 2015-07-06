package Topmed::Command::launch;

use Topmed -command;
use Topmed::Base;

sub opt_spec {
  return (
    ['verbose|v', 'Verbose output'],
    ['bam|b=s',   'BAM file to process'],
  );
}

sub validate_args {
  my ($self, $opts, $args) = @_;
}

sub execute {
  my ($self, $opts, $args) = @_;
}

1;

__END__

=head1

Topmed::Command::launch - Launch a remapping job on the next available BAM
