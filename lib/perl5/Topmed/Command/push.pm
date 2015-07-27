package Topmed::Command::push;

use Topmed -command;
use Topmed::Base qw(db);
use Topmed::Config;

sub opt_spec {
  return (
    []
  );
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

  my $db        = Topmed::DB->new();
  my $conf      = Topmed::Config->new();
  my $cache     = $conf->cache();
  my $idx_entry = $cache->entry($BAM_CACHE_INDEX);
  my $index     = $idx_entry->thaw();

  for my $bamid (keys %{$index}) {
    my $bam_entry = $cache->entry($bamid);
    my $bam_ref   = $bam_entry->thaw();

    next unless defined $bam_ref->{status};
    next if exists $bam_ref->{pushed};
    next if $bam_ref->{status} eq $BAM_STATUS{unknown};

    if ($bam_ref->{status} == $BAM_STATUS{completed}) {
      my $now = time();
      my $bam = $db->resultset('Bamfile')->find($bamid);

      unless ($bam) {
        say "Unable to locate BAM id $bamid in the database!";
        next;
      }

      say 'Setting BAM: ' . $bam->bamname . " datemapping to $now" if $self->app->global_options->{verbose};

      $bam->update(
        {
          datemapping => $now
        }
      );

      $bam_ref->{pushed} = 1;
      $bam_entry->freeze($bam_ref);
    }
  }
}

1;

__END__

=head1

Topmed::Command::push - Push results to the topmed database
