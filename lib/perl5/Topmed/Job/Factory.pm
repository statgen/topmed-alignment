package Topmed::Job::Factory;

use MooseX::AbstractFactory;

implementation_does [qw(Topmed::Job::Factory::Implementation::Requires)];
implementation_class_via sub {'Topmed::Job::Factory::Implementation::' . shift};

1;
