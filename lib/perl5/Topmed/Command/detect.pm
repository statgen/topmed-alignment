package Topmed::Command::detect;

use Topmed -command;
use Topmed::Base qw(db);
use Topmed::Config;

sub opt_spec {
  return ([]);
}

sub validate_args {
  my ($self, $opts, $args) = @_;

  if ($self->app->global_options->{help}) {
    print $self->app->usage->text;
    exit;
  }
}

sub execute {
  my ($self, $opts, $args) = @_;

  my $db          = Topmed::DB->new();
  my $conf        = Topmed::Config->new();
  my $cache       = $conf->cache();
  my @cached_bams = ();

  for my $bam ($db->resultset('Bamfile')->all()) {
    next if $bam->datearrived =~ /\D/;    # XXX - not sure, logic from TPG
    next if $bam->datearrived < 10;       # XXX - not sure, logic from TPG

    # TODO - only cache bams that need to be processed
    # TODO - check for existing cache entry and update
    say 'Caching BAM: ' . $bam->bamname if $self->app->global_options->{verbose};
    my $entry = $cache->entry($bam->bamid);
    $entry->freeze(
      {
        id     => $bam->bamid,
        name   => $bam->bamname,
        dir    => $bam->run->dirname,
        center => $bam->run->center->centername,
        pi     => $bam->piname,
        study  => $bam->studyname,                 # XXX - should come from $bam->study->studyname but nothing in that table atm
        status => $bam->status,
      }
    );

    push @cached_bams, $bam->bamid;
  }

  my $idx_ref   = {};
  my $idx_entry = $cache->entry($BAM_CACHE_INDEX);

  if ($idx_entry->exists) {
    say "Updating $BAM_CACHE_INDEX" if $self->app->global_options->{verbose};

    $idx_ref = $idx_entry->thaw();

    map {$idx_ref->{$_} = 1} @cached_bams;
    $idx_entry->freeze($idx_ref);

  } else {
    say "Creating $BAM_CACHE_INDEX" if $self->app->global_options->{verbose};

    map {$idx_ref->{$_} = 1} @cached_bams;
    $idx_entry->freeze($idx_ref);
  }

}

1;

__END__

=head1

Topmed::Command::detect - Detect new BAM files to process
