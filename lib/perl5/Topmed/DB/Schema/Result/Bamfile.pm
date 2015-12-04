use utf8;
package Topmed::DB::Schema::Result::Bamfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Topmed::DB::Schema::Result::Bamfile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime");

=head1 TABLE: C<bamfiles>

=cut

__PACKAGE__->table("bamfiles");

=head1 ACCESSORS

=head2 bamid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 runid

  data_type: 'integer'
  is_nullable: 0

=head2 studyid

  data_type: 'integer'
  is_nullable: 0

=head2 bamname

  data_type: 'varchar'
  is_nullable: 0
  size: 96

=head2 studyname

  data_type: 'varchar'
  is_nullable: 0
  size: 96

=head2 piname

  data_type: 'varchar'
  is_nullable: 1
  size: 96

=head2 phs

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 phs_consent_short_name

  data_type: 'varchar'
  is_nullable: 1
  size: 24

=head2 phs_sra_sample_id

  data_type: 'varchar'
  is_nullable: 1
  size: 24

=head2 phs_sra_data_details

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 checksum

  data_type: 'varchar'
  is_nullable: 0
  size: 96

=head2 refname

  data_type: 'varchar'
  is_nullable: 0
  size: 96

=head2 expt_refname

  data_type: 'varchar'
  is_nullable: 0
  size: 96

=head2 expt_sampleid

  data_type: 'varchar'
  is_nullable: 0
  size: 24

=head2 datearrived

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datemd5ver

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 dateqplot

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datemapping

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datereport

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datebackup

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datecram

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datebai

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datecp2ncbi

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidarrived

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidmd5ver

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidbackup

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidcram

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidbai

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidqplot

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidmapping

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 jobidcp2ncbi

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 bamsize

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 16

=head2 dateinit

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=cut

__PACKAGE__->add_columns(
  "bamid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "runid",
  { data_type => "integer", is_nullable => 0 },
  "studyid",
  { data_type => "integer", is_nullable => 0 },
  "bamname",
  { data_type => "varchar", is_nullable => 0, size => 96 },
  "studyname",
  { data_type => "varchar", is_nullable => 0, size => 96 },
  "piname",
  { data_type => "varchar", is_nullable => 1, size => 96 },
  "phs",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "phs_consent_short_name",
  { data_type => "varchar", is_nullable => 1, size => 24 },
  "phs_sra_sample_id",
  { data_type => "varchar", is_nullable => 1, size => 24 },
  "phs_sra_data_details",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "checksum",
  { data_type => "varchar", is_nullable => 0, size => 96 },
  "refname",
  { data_type => "varchar", is_nullable => 0, size => 96 },
  "expt_refname",
  { data_type => "varchar", is_nullable => 0, size => 96 },
  "expt_sampleid",
  { data_type => "varchar", is_nullable => 0, size => 24 },
  "datearrived",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datemd5ver",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "dateqplot",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datemapping",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datereport",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datebackup",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datecram",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datebai",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datecp2ncbi",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidarrived",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidmd5ver",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidbackup",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidcram",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidbai",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidqplot",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidmapping",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "jobidcp2ncbi",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "bamsize",
  { data_type => "varchar", default_value => 0, is_nullable => 1, size => 16 },
  "dateinit",
  { data_type => "varchar", is_nullable => 1, size => 10 },
);

=head1 PRIMARY KEY

=over 4

=item * L</bamid>

=back

=cut

__PACKAGE__->set_primary_key("bamid");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-09-01 08:27:13
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:eu9jw1DalX16MIgd/f4pcg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
#
use Topmed::Base;
use Topmed::Config;

__PACKAGE__->belongs_to(
  run => 'Topmed::DB::Schema::Result::Run',
  {'foreign.runid' => 'self.runid'}
);

__PACKAGE__->belongs_to(
  study => 'Topmed::DB::Schema::Result::Study',
  {'foreign.studyid' => 'self.studyid'}
);

__PACKAGE__->belongs_to(
  mapping => 'Topmed::DB::Schema::Result::Mapping',
  {'foreign.bam_id' => 'self.bamid'}
);

sub status {
  no if $PERL_VERSION >= 5.017011, warnings => 'experimental::smartmatch';

  given (shift->datemapping) {
    when (not defined($_))              {return $BAM_STATUS{requested}}
    when ($BAM_STATUS{unknown})         {return $BAM_STATUS{requested}}
    when ($BAM_STATUS{cancelled})       {return $BAM_STATUS{cancelled}}
    when ($BAM_STATUS{requested})       {return $BAM_STATUS{requested}}
    when ($BAM_STATUS{failed})          {return $BAM_STATUS{failed}}
    when ($BAM_STATUS{submitted})       {return $BAM_STATUS{submitted}}
    when ($_ >= $BAM_STATUS{completed}) {return $BAM_STATUS{completed}}
    when ($_ < 0)                       {return $BAM_STATUS{started}}
    default                             {return $BAM_STATUS{requested}}
  }
}

sub has_arrived {
  my ($self) = @_;

  # XXX - not sure, logic from TPG
  return defined $self->datearrived;
  return undef if $self->datearrived =~ /\D/;
  return undef if $self->datearrived < 10;
}

sub status_line {
  my ($self) = @_;
  my %r_bam_status = reverse %BAM_STATUS;
  return sprintf $BAM_STATUS_LINE_FMT,
    $self->bamid,
    $self->bamname,
    $self->run->center->centername,
    $self->studyname,
    $self->piname // 'unknown',
    $r_bam_status{$self->status},
    $self->mapping->cluster // 'unknown';
}

1;
