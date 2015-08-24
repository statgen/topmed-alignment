#!/usr/bin/env perl

use File::Slurp::Tiny qw(read_lines read_file);
use File::Basename;
use List::MoreUtils qw(any indexes);
use File::Basename;
use Topmed::Base;
use Topmed::DB;
use Topmed::Config;

my $align_status = q{/net/1000g/hmkang/etc/nowseq/topmed/topmed.latest.alignstatus};
my @results      = parse_align_status($align_status);
my $db           = Topmed::DB->new();
my $config       = Topmed::Config->new();

for my $result (@results) {
  my @indexes = indexes {$_->{state} =~ /ALIGN_COMPLETE/} @{$result->{results}};

  if (@indexes) {
    my $record = $result->{results}->[$indexes[0]];
    my $path   = Path::Class::File->new($result->{orig_bam});
    my @comps  = $path->components();
    my $name   = $comps[-1];
    my $bam    = $db->resultset('Bamfile')->search({bamname => $name})->first;

    unless (defined $bam) {
      print Dumper $record;
    } elsif ($bam->status != $BAM_STATUS{completed}) {
      #print Dumper $bam->bamid . ' => ' . $bam->datemapping . ' => ' . $bam->mapping->status;
      #
      next unless $bam->mapping->cluster;
      if ($bam->mapping->cluster eq 'csg') {
#       chomp(my $job_state = capture(EXIT_ANY, sprintf $JOB_STATE_CMD_FORMAT{$bam->mapping->cluster}, $bam->mapping->job_id));
#       run('scancel ' . $bam->mapping->job_id);
#       $bam->update({datemapping => time()});
#       $bam->mapping->update({status => $bam->datemapping});
#       say 'cancelled ' . $bam->mapping->job_id;
      } elsif ($bam->mapping->cluster eq 'flux') {
        chomp(my $job_state = capture(EXIT_ANY, sprintf $JOB_STATE_CMD_FORMAT{$bam->mapping->cluster}, $bam->mapping->job_id));
        print Dumper $bam->bamid;
      }
    }
  }

# my @indexes = indexes {$_->{state} =~ /ALIGN_COMPLETE/} @{$result->{results}};
# if (@indexes) {
#   my $record = $result->{results}->[$indexes[0]];
#   my $path   = Path::Class::File->new($result->{orig_bam});
#   my @comps  = $path->components();
#   my $name   = $comps[-1];
#   my $bam    = $db->resultset('Bamfile')->search({bamname => $name})->first;

#   if ($bam->status < $BAM_STATUS{completed}) {
#     next unless $bam->mapping->cluster;
#     next if $bam->mapping->cluster eq 'csg';
#     (my $job_id = $bam->mapping->job_id) =~ s/\.nyx(?:\.arc\-ts\.umich\.edu)?//g;

#     chomp(my $job_state = capture(EXIT_ANY, sprintf $JOB_STATE_CMD_FORMAT{$bam->mapping->cluster}, $job_id));

#     if ($job_state =~ /running/i) {
#       say 'Completing BAM: ' . $bam->mapping->job_id;
#        run('scancel ' . $bam->mapping->job_id);
#        $bam->update({datemapping => $BAM_STATUS{completed}});
#        $bam->mapping->update({status => $BAM_STATUS{completed}});

#     } elsif ($job_state =~ /pending/i) {
#       say 'Completing BAM: ' . $bam->mapping->job_id;
#        run('scancel ' . $bam->mapping->job_id);
#        $bam->update({datemapping => $BAM_STATUS{completed}});
#        $bam->mapping->update({status => $BAM_STATUS{completed}});

#     } elsif ($job_state =~ /cancel/i) {
#       say 'Marking complete just in case ' . $bam->mapping->job_id;
#        $bam->update({datemapping => $BAM_STATUS{completed}});
#        $bam->mapping->update({status => $BAM_STATUS{completed}});
#     } elsif ($job_state == 0) {
#       run('qdel ' . $job_id);

#       my $now = time();
#       $bam->update({datemapping => $now});
#       $bam->mapping->update({status => $now});

#       say $bam->status_line . 'State: [' . $job_state . ']' . ' JOBID: ' . $job_id;
#     } else {
#       say $bam->status_line;
#     }
#   }
# }

# my @indexes = indexes {$_->{state} =~ /ALIGN_COMPLETE/} @{$result->{results}};
# if (scalar @indexes > 1) {
#   for my $index (@indexes) {
#     my $dir = $result->{results}->[$index]->{result};
#     if (basename($dir) =~ /^LP/) {
#       say $dir;
#       #run("rm -rf $dir");
#     }
#   }
# }
# next;

  # my @indexes = indexes {$_->{state} =~ /QPLOT/} @{$result->{results}};
  # if (@indexes) {
  #   my $result = $result->{results}->[$indexes[0]];

  #   if ($result->{state} =~ /DUP_QPLOT/) {
  #     if (-e $result->{result}) {
  #       say "Deleteing RESULT: $result->{result}";
  #       run("rm -rf $result->{result}");
  #     }
  #     next;
  #   }

  #   my $bam = $db->resultset('Bamfile')->search({bamname => {like => basename($result->{result}) . '%'}})->first();

  #   unless ($bam) {
  #     if (-e $result->{result}) {
  #       say "Deleteing RESULT: $result->{result}";
  #       run("rm -rf $result->{result}");
  #     }
  #     next;
  #   }

  #   say "Deleteing RESULT: $result->{result}";
  #   run("rm -rf $result->{result}");

  #   say 'Resubmitting BAM: ' . $bam->bamid;
  #   run('bin/topmed resubmit -b ' . $bam->bamid);
  # }

  # my @indexes = indexes {$_->{state} =~ /ALIGN_FAILED/} @{$result->{results}};
  # if (@indexes) {
  #   my $result = $result->{results}->[$indexes[0]];

  #   say "Deleteing RESULT: $result->{result}";
  #   run("rm -rf $result->{result}");

  #   my $bam = $db->resultset('Bamfile')->search({bamname => {like => basename($result->{result}) . '%'}})->first();

  #   next unless $bam;

  #   my %r_status = reverse %BAM_STATUS;
  #   my $status   = $r_status{$bam->status};

  #   given ($status) {
  #     when (/failed|completed/) {
  #       say 'Resubmitting BAM: ' . $bam->bamid;
  #       run('bin/topmed resubmit -b ' . $bam->bamid);
  #     }
  #     when (/requested/) {
  #       say 'BAM: ' . $bam->bamid . ' is in correct state';
  #     }
  #     default {
  #       die 'UNKNOWN STATUS';
  #     }
  #   }
  # }

  # my @indexes = indexes {$_->{state} eq 'ALIGN_COMPLETE_NO_OK'} @{$result->{results}};
  # if (@indexes) {
  #   my $index = $result->{results}->[$indexes[0]];
  #   my $dir   = $index->{result};
  #   my $file  = $dir . '/' . basename($dir) . '.OK';

  #   say("touch $file");
  # }

  # if (any {$_->{state} =~ /DUP_/} @{$result->{results}}) {
  #   if (any {$_->{state} =~ 'ALIGN_COMPLETE'} @{$result->{results}}) {

  #     for (@{$result->{results}}) {
  #       run(qq{rm -rf $_->{result}}) if $_->{state} =~ /DUP/;
  #     }
  #   }
  # }
}

sub parse_align_status {
  my $file = shift;

  my @results = ();
  for my $line (read_lines($file)) {
    chomp($line);
    my @parts = split(/\s/, $line);

    my $result_ref = {
      sampleid => $parts[0],
      orig_bam => $parts[1],
      results  => [],
    };

    if ($parts[2] =~ /\,/) {
      my @results = split(/,/, $parts[2]);
      my @states  = split(/,/, $parts[3]);

      for (0 .. $#results) {
        push @{$result_ref->{results}}, {result => $results[$_], state => $states[$_]};
      }
    } else {
      push @{$result_ref->{results}}, {result => $parts[2], state => $parts[3]};
    }

    push @results, $result_ref;
  }

  return @results;
}


