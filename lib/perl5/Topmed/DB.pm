package Topmed::DB;

use base qw(Topmed::DB::Schema);

use Topmed::Base qw(cids);
use Topmed::Config;
use Topmed::DB::Schema;

sub new {
  my $conf = Topmed::Config->new();
  return __PACKAGE__->connect($conf->dsn, $conf->db_user, $conf->db_pass);
}

1;
