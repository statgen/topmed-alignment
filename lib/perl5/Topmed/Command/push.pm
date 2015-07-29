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
    say $self->app->usage->text;
    print $self->usage->text;
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
  my $now       = time();

  for my $bamid (keys %{$index}) {
    my $bam_entry = $cache->entry($bamid);
    my $bam_ref   = $bam_entry->thaw();
    my $bam       = $db->resultset('Bamfile')->find($bamid);

    unless ($bam) {
      say "Unable to locate BAM id $bamid in the database!";
      next;
    }

    unless ($bam_ref->{status}) {
      say "Found undefined status for $bamid in the cache" if $self->app->global_options->{verbose};
      next;
    }

    next if $bam->status >= $BAM_STATUS{completed};
    my $status = ($bam_ref->{status} >= $BAM_STATUS{completed}) ? $now : $bam_ref->{status};
    say 'Setting BAM: ' . $bam->bamname . " datemapping to $status" if $self->app->global_options->{verbose};

    $bam->update(
      {
        datemapping  => $status,
        jobidmapping => $bam_ref->{jobid},
      }
    );
  }
}

1;

__END__

=head1

Topmed::Command::push - Push results to the topmed database
