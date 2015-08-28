package Topmed::Job::Factory::Implementation::Flux;

use Topmed::Base qw(:www);
use Topmed::Config;

use Moose;

has 'job_id' => (is => 'ro', isa => 'Int', required => 1);

sub elapsed {
  my ($self) = @_;
  return 42;
}

sub state {
  my ($self) = @_;
  return q{running};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
