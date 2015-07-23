package Topmed::Config;

use base qw(Exporter);
use Topmed::Base;
use Moose;

our @EXPORT = (
  qw(
    $BATCH_SCRIPT
    %JOB_CMDS
    $BAM_CACHE_INDEX
    %BAM_FILE_PREFIX
    %BAM_STATUS
    @TIME_REMAINING_FORMAT_REGEXPS
    )
);

our @EXPORT_OK = (
  qw(
    $BATCH_SCRIPT
    %JOB_CMDS
    $BAM_CACHE_INDEX
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
      $BAM_CACHE_INDEX
      %BAM_FILE_PREFIX
      %BAM_STATUS
      @TIME_REMAINING_FORMAT_REGEXPS
      )
  ]
);

Readonly::Scalar our $BATCH_SCRIPT    => qq{$Bin/../align.sh};
Readonly::Scalar our $BAM_CACHE_INDEX => 'bam_idx';

Readonly::Hash our %BAM_FILE_PREFIX => (
  csg  => '/net/topmed/incoming/topmed',
  flux => '/dept/csg/topmed/incoming/topmed',
);

Readonly::Hash our %BAM_STATUS => (
  unknown   => '', # FIXME - causing errors with numeric comparisons later on, need to change
  failed    => -1,
  requested => 0,
  cancelled => 1,
  submitted => 2,
  completed => 3,
);

Readonly::Hash our %JOB_CMDS => (
  csg  => 'sbatch',
  flux => 'qsub',
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
);

Readonly::Scalar my $CACHE_ROOT         => qq{$Bin/../../cache};
Readonly::Scalar my $DB_CONNECTION_INFO => q{/usr/cluster/monitor/etc/.db_connections/topmed};

has '_conn'   => (is => 'ro', isa => 'HashRef',     lazy => 1, builder => '_build__conn');
has 'db'      => (is => 'ro', isa => 'Str',         lazy => 1, builder => '_build_db');
has 'db_user' => (is => 'ro', isa => 'Str',         lazy => 1, builder => '_build_db_user');
has 'db_pass' => (is => 'ro', isa => 'Str',         lazy => 1, builder => '_build_db_pass');
has 'db_host' => (is => 'ro', isa => 'Str',         lazy => 1, builder => '_build_db_host');
has 'db_port' => (is => 'ro', isa => 'Str',         lazy => 1, builder => '_build_db_port');
has 'dsn'     => (is => 'ro', isa => 'Str',         lazy => 1, builder => '_build_dsn');
has 'cache'   => (is => 'ro', isa => 'Cache::File', lazy => 1, builder => '_build_cache');

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

sub _build_cache {
  return Cache::File->new(cache_root => $CACHE_ROOT, lock_level => Cache::File::LOCK_NFS);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
