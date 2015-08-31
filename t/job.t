#!/usr/bin/env perl

use FindBin qw($Bin);
use lib qq{$Bin/../t/tests}, qq{$Bin/../lib/perl5};

use Test::Topmed::Job::Factory;

Test::Class->runtests;
