package Topmed::Command::stat;

use Topmed -command;
use Topmed::Base;
use Topmed::Config;

sub opt_spec {
  return (
    ['time_left|t=s', 'Parse time remaining and return hours left'],
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
}

sub parse_time {
  my ($time) = @_;

  for my $regexp (@TIME_REMAINING_FORMAT_REGEXPS) {
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
