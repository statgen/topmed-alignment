#!/usr/bin/env perl

use FindBin qw($Bin);
use lib qq{$Bin/../t/tests}, qq{$Bin/../lib/perl5};

use Test::Topmed::BAM;

Test::Class->runtests;
