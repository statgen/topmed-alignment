package Topmed::Base;

use base qw(Import::Base);

our @IMPORT_MODULES = (
  'FindBin' => [qw($Bin)],
  'English' => [qw(-no_match_vars)],
  'Modern::Perl',
  'Data::Dumper',
  'System::Command',
  'Readonly',
  'File::Slurp::Tiny' => [qw(read_file read_lines)],
  'File::Spec',
  'File::Basename',
  'File::Stat',
  'List::MoreUtils' => [qw(all any none)],
  'Path::Class',
  'IPC::System::Simple' => [qw(run capture EXIT_ANY)],
  'DateTime',
  'Class::CSV',
  'Cwd' => [qw(abs_path)],
);

our %IMPORT_BUNDLES = (
  www => [
    qw(
      URI
      URI::QueryParam
      JSON::MaybeXS
      Mojo::UserAgent
      )
  ]
);

1;
