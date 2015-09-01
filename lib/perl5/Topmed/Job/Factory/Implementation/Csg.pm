package Topmed::Job::Factory::Implementation::Csg;

use Topmed::Base;
use Topmed::Config;
use Topmed::Util qw(parse_time);

use Moose;

has 'job_id' => (is => 'ro', isa => 'Int', required => 1);

sub elapsed {
  my ($self) = @_;
  my $cmd = sprintf $JOB_ELAPSED_TIME_FORMAT{csg}, $self->job_id;
  chomp(my $time = capture(EXIT_ANY, $cmd));
  return parse_time($time);
}

sub state {
  my ($self) = @_;
  my $cmd = sprintf $JOB_STATE_CMD_FORMAT{csg}, $self->job_id;
  chomp(my $state = capture(EXIT_ANY, $cmd));
  $state =~ s/^\s+|\s+$//g;
  return $JOB_STATES{$state};
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

