package Topmed::BAM;

use Topmed::Base;
use Topmed::Config;
use Moose;

has 'prefix'    => (is => 'ro', isa => 'Str', required => 1);
has 'id'        => (is => 'ro', isa => 'Int', required => 1);
has 'sample_id' => (is => 'ro', isa => 'Str', required => 1);
has 'center'    => (is => 'ro', isa => 'Str', required => 1);
has 'dir'       => (is => 'ro', isa => 'Str', required => 1);
has 'name'      => (is => 'ro', isa => 'Str', required => 1);

has 'path' => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_path');
has 'host' => (is => 'ro', isa => 'Str', lazy => 1, builder => '_build_host');


sub _build_path {
  my ($self) = @_;

}

sub _build_host {
  my ($self) = @_;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
