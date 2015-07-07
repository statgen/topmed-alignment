package Topmed::Config;

use Topmed::Base;
use Moose;

Readonly::Scalar my $DB_CONNECTION_INFO => q{/usr/cluster/monitor/etc/.db_connections/topmed};

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
