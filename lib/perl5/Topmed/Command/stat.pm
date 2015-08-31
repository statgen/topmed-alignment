package Topmed::Command::stat;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;
use Topmed::DB;

sub opt_spec {
  return (
    ['time_left|t=s', 'Parse time remaining and return hours left'],
    ['totals',        'Print totals for various bits'],
    );
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($opts->{time_left} and none {$opts->{time_left} =~ $_} @TIME_REMAINING_FORMAT_REGEXPS) {
    $self->usage_error('Invalid time format');
  }

  if ($self->app->global_options->{help}) {
    say $self->app->usage->text;
    print $self->usage->text;
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  if ($opts->{time_left}) {
    say parse_time($opts->{time_left});
    exit 0;
  }

  if ($opts->{totals}) {
    my $db = Topmed::DB->new();
    printf "Completed: %-10d (flux: %d csg: %d unknown: %d)\n",
      $db->resultset('Mapping')->search({status => {'>=' => $BAM_STATUS{completed}}})->count(),
      $db->resultset('Mapping')->search({status => {'>=' => $BAM_STATUS{completed}}, cluster => 'flux'})->count(),
      $db->resultset('Mapping')->search({status => {'>=' => $BAM_STATUS{completed}}, cluster => 'csg'})->count(),
      $db->resultset('Mapping')->search({status => {'>=' => $BAM_STATUS{completed}}, cluster => undef})->count();
    printf "Failed: %4d\n",    $db->resultset('Bamfile')->search({datemapping => $BAM_STATUS{failed}})->count();
    printf "Submitted: %-10d (pending/running)\n", $db->resultset('Mapping')->search({status => $BAM_STATUS{submitted}})->count();
    printf "Requested: %-10d (ready for submission)\n", $db->resultset('Mapping')->search({status => $BAM_STATUS{requested}})->count();
    printf "Cancelled: %d\n", $db->resultset('Mapping')->search({status => $BAM_STATUS{cancelled}})->count();
    say '-' x 15;
    printf "Total: %8d\n",     $db->resultset('Mapping')->search()->count();
  }
}

sub parse_time {
  my ($time) = @_;

  for my $regexp (@TIME_FORMAT_REGEXPS) {
    if ($time =~ $regexp) {
      return (($+{days} * 24) + $+{hours}) if $+{days} and $+{hours};
      return $+{hours} if $+{hours};
      return int($+{seconds} / 60 / 60) if $+{seconds};
    }
  }

  return 0;
}

1;

__END__

=head1

Topmed::Command::stat - Various stats for jobs
