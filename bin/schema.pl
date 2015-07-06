#!/usr/bin/env perl
#
use FindBin qw($Bin);
use lib qq($$Bin/../lib/perl5);
use Topmed::Base;

make_schema_at(
  'Topmed::DB::Schema', {
    debug => 1,
    dump_directory => qq($Bin/../lib/perl5),
  },
  [$config->dsn, $config->db_user, $config->db_pass]
);
