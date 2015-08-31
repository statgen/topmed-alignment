package Test::Topmed::Job::Factory;

use base qw(Test::Class);

use Test::Most;
use Test::More;
use DateTime::Duration;

use Topmed::Job::Factory;

sub class {
  return q{Topmed::Job::Factory};
}

sub startup : Test(startup => 1) {
  my ($test) = @_;

  $test->{fixtures}->{clusters} = {
    Csg => {
      job_id  => 12520268,
      elasped => 42,
      state   => 'completed',
    },
    Flux => {
      job_id  => 456,
      elapsed => 42,
      state   => 'completed',
    }
  };

  can_ok($test->class, 'create');
}

sub setup : Test(setup) {
  my ($test) = @_;

  for my $key (keys %{$test->{fixtures}->{clusters}}) {
    my $cluster = $test->{fixtures}->{clusters}->{$key};
    $test->{fixtures}->{jobs}->{$key} = $test->class->create($key, {job_id => $cluster->{job_id}});
  }
}

sub test_elapsed_csg_imp : Test(3) {
  my ($test) = @_;
  my $job = $test->{fixtures}->{jobs}->{Csg};

  # 2-22:30:45
  my $elapsed = DateTime::Duration->new(
    days    => 2,
    hours   => 22,
    minutes => 30,
    seconds => 45,
  );

  can_ok($job, 'elapsed');
  isa_ok($job->elapsed, 'DateTime::Duration');
  is($job->elapsed->seconds, $elapsed->seconds, 'elapsed seconds match');
}

sub test_state_csg_imp : Test(2) {
  my ($test) = @_;
  my $job = $test->{fixtures}->{jobs}->{Csg};

  can_ok($job, 'state');
  is($job->state, 'completed', 'state matches');
}

sub test_flux_meths : Test(2) {
  my ($test) = @_;

  my $url =
    q{https://kibana.arc-ts.umich.edu/logstash-joblogs-2015.*/pbsacctlog/_search?fields=resources_used.walltime&q=jobid%3A456};
  my $job = $test->{fixtures}->{jobs}->{Flux};
  can_ok($job, '_logstash_url');
  is($job->_logstash_url, $url, 'logstash url matches');
}

1;
