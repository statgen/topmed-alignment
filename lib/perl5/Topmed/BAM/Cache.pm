package Topmed::BAM::Cache;

use Topmed::Base;
use Topmed::Config;

use Moose;

Readonly::Scalar my $MAX_PARTS => 1000;

has '_cache' => (is => 'ro', isa => 'Cache::File', lazy => 1, builder => '_build__cache');
has 'index'  => (is => 'ro', isa => 'ArrayRef',    lazy => 1, builder => '_build_index');

sub _build__cache {
  return Cache::File->new(cache_root => $CACHE_ROOT, lock_level => Cache::File::LOCK_NFS);
}

sub _build_index {
  return shift->_cache->entry('bam_idx_new')->thaw();
}

sub load {
  my ($self) = @_;
  my $index = $self->index();
}

sub find {
  my ($self, $id) = @_;

  my $index = $self->index;
  my $hunk  = ($id % $MAX_PARTS) - 1;
  my $pos   = first_index {exists $_->{$id}} @{$index[$hunk]};

  return $index[$hunk][$pos]->{$id};
}

sub find_by_state {
  my ($self, $state) = @_;
}

__PACKAGE__->meta->make_immutable;

1;
