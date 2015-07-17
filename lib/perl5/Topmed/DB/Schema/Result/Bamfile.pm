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
  "bamid", {data_type => "integer", is_auto_increment => 1, is_nullable => 0},
  "runid", {data_type => "integer", is_nullable => 0},
  "studyid",       {data_type => "integer", is_nullable   => 0},
  "bamname",       {data_type => "varchar", is_nullable   => 0, size => 96},
  "studyname",     {data_type => "varchar", is_nullable   => 0, size => 96},
  "piname",        {data_type => "varchar", is_nullable   => 1, size => 96},
  "checksum",      {data_type => "varchar", is_nullable   => 0, size => 96},
  "refname",       {data_type => "varchar", is_nullable   => 0, size => 96},
  "expt_refname",  {data_type => "varchar", is_nullable   => 0, size => 96},
  "expt_sampleid", {data_type => "varchar", is_nullable   => 0, size => 24},
  "datearrived",   {data_type => "varchar", is_nullable   => 1, size => 12},
  "datemd5ver",    {data_type => "varchar", is_nullable   => 1, size => 12},
  "dateqplot",     {data_type => "varchar", is_nullable   => 1, size => 12},
  "datemapping",   {data_type => "varchar", is_nullable   => 1, size => 12},
  "datereport",    {data_type => "varchar", is_nullable   => 1, size => 12},
  "datebackup",    {data_type => "varchar", is_nullable   => 1, size => 12},
  "datebai",       {data_type => "varchar", is_nullable   => 1, size => 12},
  "datecp2ncbi",   {data_type => "varchar", is_nullable   => 1, size => 12},
  "jobidarrived",  {data_type => "varchar", is_nullable   => 1, size => 12},
  "jobidmd5ver",   {data_type => "varchar", is_nullable   => 1, size => 12},
  "jobidbackup",   {data_type => "varchar", is_nullable   => 1, size => 12},
  "jobidbai",      {data_type => "varchar", is_nullable   => 1, size => 12},
  "jobidqplot",    {data_type => "varchar", is_nullable   => 1, size => 12},
  "jobidmapping",  {data_type => "varchar", is_nullable   => 1, size => 12},
  "jobidcp2ncbi",  {data_type => "varchar", is_nullable   => 1, size => 12},
  "bamsize",       {data_type => "varchar", default_value => 0, is_nullable => 1, size => 16},
  "dateinit", {data_type => "varchar", is_nullable => 1, size => 10},
);

=head1 PRIMARY KEY

=over 4

=item * L</bamid>

=back

=cut

__PACKAGE__->set_primary_key("bamid");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-07-07 09:49:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+6XUDVmMr83Ut0Ggm27suA


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

sub status {
  no if $PERL_VERSION >= 5.017011, warnings => 'experimental::smartmatch';

  given (shift->datemapping) {
    when (not defined($_))        {return $BAM_STATUS{requested}}
    when ($BAM_STATUS{unknown})   {return $BAM_STATUS{unknown}}
    when ($BAM_STATUS{cancelled}) {return $BAM_STATUS{cancelled}}
    when ($BAM_STATUS{requested}) {return $BAM_STATUS{requested}}
    when ($BAM_STATUS{failed})    {return $BAM_STATUS{failed}}
    when ($BAM_STATUS{submitted}) {return $BAM_STATUS{submitted}}
    when ($_ > 10)                {return $BAM_STATUS{completed}}
    when ($_ < 0)                 {return $BAM_STATUS{started}}
    default                       {return $BAM_STATUS{unknown}}
  }
}

1;
