package Test::Topmed::Job::Factory;

use base qw(Test::Class);

use Test::Most;

sub class {
  return q{Topmed::Job::Factory};
}

sub startup : Test(startup => 1) {
  my ($test) = @_;

  $test->{fixtures}->{clusters} = {
    csg => {
      job_id  => 123,
      elasped => 42,
      state   => 'completed',
    },
    flux => {
      job_id  => 456,
      elapsed => 42,
      state   => 'completed',
    }
  };

  can_ok($test->class, 'create', 'can create new objects');
}

sub setup : Test(setup) {
  my ($test) = @_;

  for my $key (keys %{$test->{fixtures}->{clusters}}) {
    my $cluster = $test->{fixtures}->{clusters}->{$key};
    push @{$test->{fixtures}->{jobs}}, $test->class->create($key, {job_id => $cluster->{job_id});
  }
}

sub test_elapsed : Test(2) {
  my ($test) = @_;

  for my $job (@{$test->{fixtures}->{jobs}}) {
    is($job->elapsed, 42, 'elapsed time matches');
  }
}

sub test_state : Test(2) {
  my ($test) = @_;

  for my $job (@{$test->{fixtures}->{jobs}}) {
    is($job->state, 'running', 'elapsed time matches');
  }
}

1;
