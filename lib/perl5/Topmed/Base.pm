package Topmed::Base;

use base qw(Import::Base);

our @IMPORT_MODULES = (
  'Modern::Perl',
  'Cache',
  'Data::Dumper',
  'System::Command',
  'Readonly',
  'File::Slurp::Tiny' => [qw(read_file read_lines)],
);

our %IMPORT_BUNDLES = (
  db => [
    'Topmed::DB'
  ]
);

1;
