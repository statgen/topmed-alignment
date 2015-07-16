package Topmed::Base;

use base qw(Import::Base);

our @IMPORT_MODULES = (
  'Modern::Perl',
  'Cache::File',
  'Data::Dumper',
  'System::Command',
  'Readonly',
  'File::Slurp::Tiny' => [qw(read_file read_lines)],
  'Class::CSV'
);

our %IMPORT_BUNDLES = (
  db => [
    'Topmed::DB'
  ]
);

1;
