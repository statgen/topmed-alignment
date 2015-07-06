package Topmed::Command::update;

use Topmed -command;
use Topmed::Base;

sub opt_spec {
  return (
    ['verbose|v',    'Verbose output'],
    ['bam|b=s',      'bam file to update'],
    ['processing|p', 'mark the bam file as in process'],
    ['finished|f',   'mark the bam file finished'],
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

Topmed::Command::update - Update the status of a BAM
