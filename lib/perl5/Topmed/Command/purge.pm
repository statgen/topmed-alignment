package Topmed::Command::purge;

use Topmed -command;
use Topmed::Base qw(db);
use Topmed::Config;

sub opt_spec {
  return (
    ['dry_run|n',   'Dry run; Do everything except delete the bam'],
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

  my $db    = Topmed::DB->new();
  my $conf  = Topmed::Config->new();
  my $cache = $conf->cache();
  my $bams  = $db->resultset('Bamfile')->search(
    {
      datemapping => {'>' => \$BAM_STATUS{completed}}
    }
  );

  while (my $bam = $bams->next()) {
    my $entry = $cache->entry($bam->bamid);
    next unless $entry->exists();

    my $bam_ref = $entry->thaw();

    if ($bam_ref->{status} == $BAM_STATUS{completed}) {

      say 'Purging BAM: ' . $bam->bamid . ' from cache' if $self->app->global_options->{verbose};

      unless ($opts->{dry_run}) {
        $entry->remove();
      }
    } else {
      say 'Status of BAM ' . $bam->bamid . ' do not match in database and cache!';
      next;
    }
  }
}

1;

__END__

=head1

Topmed::Command::purge - Purge cache of completed BAMs
