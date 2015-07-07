use utf8;
package Topmed::DB::Schema::Result::Study;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Topmed::DB::Schema::Result::Study

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<studies>

=cut

__PACKAGE__->table("studies");

=head1 ACCESSORS

=head2 studyid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 studyname

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=cut

__PACKAGE__->add_columns(
  "studyid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "studyname",
  { data_type => "varchar", is_nullable => 0, size => 64 },
);

=head1 PRIMARY KEY

=over 4

=item * L</studyid>

=back

=cut

__PACKAGE__->set_primary_key("studyid");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-07-07 09:49:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:bO0mGv0xF6GrfaD9yWHoDg


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
