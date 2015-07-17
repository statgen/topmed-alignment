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
  my $centers     = {};
  my $studies     = {};
  my $pis         = {};
  my @cached_bams = ();

  for my $bam ($db->resultset('Bamfile')->all()) {
    my $entry = $cache->entry($bam->bamid);

    $centers->{$bam->run->center->centername} = 1;
    $studies->{$bam->studyname}               = 1;
    $pis->{$bam->piname}                      = 1;

    next if $entry->exists();
    next if $bam->datearrived =~ /\D/;    # XXX - not sure, logic from TPG
    next if $bam->datearrived < 10;       # XXX - not sure, logic from TPG

    say 'Caching BAM: ' . $bam->bamname if $self->app->global_options->{verbose};
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

  if (@cached_bams) {
    say "Updating $BAM_CACHE_INDEX" if $self->app->global_options->{verbose};

    my $entry = $cache->entry($BAM_CACHE_INDEX);
    my $index = ($entry->exists) ? $entry->thaw() : {};

    map {$index->{$_} = 1} @cached_bams;
    $entry->freeze($index);
  }

  say 'Caching Centers' if $self->app->global_options->{verbose};
  my $center_entry = $cache->entry('centers');
  $center_entry->thaw($centers);

  say 'Caching Studies' if $self->app->global_options->{verbose};
  my $study_entry = $cache->entry('studies');
  $study_entry->thaw($studies);

  say 'Caching PIs' if $self->app->global_options->{verbose};
  my $pi_entry = $cache->entry('pis');
  $pi_entry->thaw($pis);
}

1;

__END__

=head1

Topmed::Command::detect - Detect new BAM files to process
