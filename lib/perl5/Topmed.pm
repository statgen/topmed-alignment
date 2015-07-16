package Topmed;
use App::Cmd::Setup -app;

sub global_opt_spec {
  return (
    ['debug|d',   'Debug output'],
    ['verbose|v', 'Verbose output'],
    ['help|h',    'Usage'],
  );
}

1;
