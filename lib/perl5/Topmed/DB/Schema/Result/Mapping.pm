use utf8;
package Topmed::DB::Schema::Result::Mapping;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Topmed::DB::Schema::Result::Mapping

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

=head1 TABLE: C<mappings>

=cut

__PACKAGE__->table("mappings");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 bam_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 center_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 run_id

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 job_id

  data_type: 'varchar'
  default_value: 0
  is_nullable: 1
  size: 45

=head2 bam_host

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 status

  data_type: 'integer'
  is_nullable: 1

=head2 cluster

  data_type: 'varchar'
  is_nullable: 1
  size: 45

=head2 delay

  data_type: 'integer'
  is_nullable: 1

=head2 created_at

  data_type: 'timestamp'
  datetime_undef_if_invalid: 1
  default_value: current_timestamp
  is_nullable: 1

=head2 modified_at

  data_type: 'datetime'
  datetime_undef_if_invalid: 1
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "bam_id",
  { data_type => "integer", default_value => 0, is_nullable => 0 },
  "center_id",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "run_id",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "job_id",
  { data_type => "varchar", default_value => 0, is_nullable => 1, size => 45 },
  "bam_host",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "status",
  { data_type => "integer", is_nullable => 1 },
  "cluster",
  { data_type => "varchar", is_nullable => 1, size => 45 },
  "delay",
  { data_type => "integer", is_nullable => 1 },
  "created_at",
  {
    data_type => "timestamp",
    datetime_undef_if_invalid => 1,
    default_value => \"current_timestamp",
    is_nullable => 1,
  },
  "modified_at",
  {
    data_type => "datetime",
    datetime_undef_if_invalid => 1,
    is_nullable => 1,
  },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<idx_bam_id>

=over 4

=item * L</bam_id>

=back

=cut

__PACKAGE__->add_unique_constraint("idx_bam_id", ["bam_id"]);


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-08-21 11:19:38
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FGW2Hd7D0QxkCEPETJmoXw


# You can replace this text with custom code or comments, and it will be preserved on regeneration
#
__PACKAGE__->belongs_to(
  bam => 'Topmed::DB::Schema::Result::Bamfile',
  {'foreign.bamid' => 'self.bam_id'}
);

__PACKAGE__->belongs_to(
  center => 'Topmed::DB::Schema::Result::Center',
  {'foreign.centerid' => 'self.center_id'}
);

__PACKAGE__->belongs_to(
  run => 'Topmed::DB::Schema::Result::Run',
  {'foreign.runid' => 'self.run_id'}
);

1;
