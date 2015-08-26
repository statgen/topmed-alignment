package Topmed::Config;

use base qw(Exporter);
use Topmed::Base;
use Moose;

our @EXPORT = (
  qw(
    $BATCH_SCRIPT
    %JOB_CMDS
    %JOB_OUTPUT_REGEXP
    %JOB_STATE_CMD_FORMAT
    $BAM_HOST_PRIMARY
    $BAM_STATUS_LINE_FMT
    $BAM_RESULTS_DIR
    %CLUSTER_PREFIX
    %BAM_FILE_PREFIX
    %BAM_STATUS
    @TIME_REMAINING_FORMAT_REGEXPS
    )
);

our @EXPORT_OK = (
  qw(
    $BATCH_SCRIPT
    %JOB_CMDS
    %JOB_OUTPUT_REGEXP
    %JOB_STATE_CMD_FORMAT
    $BAM_HOST_PRIMARY
    $BAM_STATUS_LINE_FMT
    $BAM_RESULTS_DIR
    %CLUSTER_PREFIX
    %BAM_FILE_PREFIX
    %BAM_STATUS
    @TIME_REMAINING_FORMAT_REGEXPS
    )
);

our %EXPORT_TAGS = (
  all => [
    qw(
      $BATCH_SCRIPT
      %JOB_CMDS
      %JOB_OUTPUT_REGEXP
      %JOB_STATE_CMD_FORMAT
      $BAM_HOST_PRIMARY
      $BAM_STATUS_LINE_FMT
      $BAM_RESULTS_DIR
      %CLUSTER_PREFIX
      %BAM_FILE_PREFIX
      %BAM_STATUS
      @TIME_REMAINING_FORMAT_REGEXPS
      )
  ]
);

Readonly::Scalar our $BATCH_SCRIPT        => qq{$Bin/../align.sh};
Readonly::Scalar our $BAM_HOST_PRIMARY    => 'topmed';
Readonly::Scalar our $BAM_STATUS_LINE_FMT => q{ID: %-8s %-30s center: %-10s study: %-10s PI: %-15s Status: %-10s Cluster: %-5s};
Readonly::Scalar our $BAM_RESULTS_DIR     => q{working/schelcj/results};

Readonly::Hash our %CLUSTER_PREFIX => (
  csg  => '/net',
  flux => '/dept/csg',
);

Readonly::Hash our %BAM_FILE_PREFIX => (
  csg  => qq{$CLUSTER_PREFIX{csg}/topmed/incoming/topmed},
  flux => qq{$CLUSTER_PREFIX{flux}/topmed/incoming/topmed},
);

Readonly::Hash our %BAM_STATUS => (
  unknown   => '',
  failed    => -1,
  requested => 0,
  cancelled => 1,
  submitted => 2,
  completed => 3,
);

Readonly::Hash our %JOB_CMDS => (
  csg  => '/usr/cluster/bin/sbatch',
  flux => '/usr/local/torque/bin/qsub',
);

Readonly::Hash our %JOB_OUTPUT_REGEXP => (
  flux => qr/^(?<jobid>\d+)\.nyx\.arc\-ts\.umich\.edu$/i,
  csg  => qr/^Submitted batch job (?<jobid>\d+)$/i,
);

Readonly::Hash our %JOB_STATE_CMD_FORMAT => (
#  flux => q{checkjob -v %d > /dev/null 2>&1 && echo $?},
  flux => q{qstat -f -e %d > /dev/null 2>&1 ; echo $?},
  csg  => q{sacct -j %d -X -n -o state%%7},
);

Readonly::Array our @TIME_REMAINING_FORMAT_REGEXPS => (

  # dd-hh:mm:ss
  qr/(?<days>\d{1,2})\-(?<hours>\d{1,2}):\d{2}:\d{2}/,

  # dd:hh:mm:ss
  qr/(?<days>\d{1,2}):(?<hours>\d{2}):\d{2}:\d{2}/,

  # hh:mm:ss
  qr/(?<hours>\d{1,2}):\d{2}:\d{2}/,

  # hh:mm
  qr/(?<hours>\d{1,2}):\d{2}/,

  # sssssss
  qr/(?<seconds>\d{1,7})/,
);

Readonly::Scalar my $DB_CONNECTION_INFO => qq{$Bin/../../.db_connections/topmed};

has '_conn'   => (is => 'ro', isa => 'HashRef', lazy => 1, builder => '_build__conn');
has 'db'      => (is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_db');
has 'db_user' => (is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_db_user');
has 'db_pass' => (is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_db_pass');
has 'db_host' => (is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_db_host');
has 'db_port' => (is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_db_port');
has 'dsn'     => (is => 'ro', isa => 'Str',     lazy => 1, builder => '_build_dsn');

sub _build__conn {
  my ($self) = @_;
  my $conn   = {};
  my @lines  = read_lines($DB_CONNECTION_INFO);

  for my $line (@lines) {
    chomp($line);

    if ($line =~ /^SERVER=host=(.*)?$/) {
      $conn->{server} = $1;
    } else {
      my ($key, $value) = split(/=/, $line);
      $conn->{lc($key)} = $value;
    }
  }

  return $conn;
}

sub _build_db {
  return shift->_conn->{database} // $ENV{Topmed_DB};
}

sub _build_db_user {
  return shift->_conn->{user} // $ENV{Topmed_DB_USER};
}

sub _build_db_pass {
  return shift->_conn->{pass} // $ENV{Topmed_DB_PASS};
}

sub _build_db_host {
  return shift->_conn->{server} // $ENV{Topmed_DB_HOST};
}

sub _build_db_port {
  return $ENV{Topmed_DB_PORT} // 3306;
}

sub _build_dsn {
  my ($self) = @_;
  return sprintf('dbi:mysql:database=%s;host=%s;port=%d', $self->db, $self->db_host, $self->db_port);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
