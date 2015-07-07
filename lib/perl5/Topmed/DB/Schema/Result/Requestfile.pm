use utf8;
package Topmed::DB::Schema::Result::Requestfile;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Topmed::DB::Schema::Result::Requestfile

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<requestfiles>

=cut

__PACKAGE__->table("requestfiles");

=head1 ACCESSORS

=head2 reqid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 centerid

  data_type: 'integer'
  is_nullable: 0

=head2 hostname

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 fetchpath

  data_type: 'varchar'
  is_nullable: 0
  size: 255

=head2 daterequestor

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 iprequestor

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 ipuser

  data_type: 'varchar'
  is_nullable: 1
  size: 16

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 127

=cut

__PACKAGE__->add_columns(
  "reqid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "centerid",
  { data_type => "integer", is_nullable => 0 },
  "hostname",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "fetchpath",
  { data_type => "varchar", is_nullable => 0, size => 255 },
  "daterequestor",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "iprequestor",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "ipuser",
  { data_type => "varchar", is_nullable => 1, size => 16 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 127 },
);

=head1 PRIMARY KEY

=over 4

=item * L</reqid>

=back

=cut

__PACKAGE__->set_primary_key("reqid");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-07-07 09:49:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BAkVwlJXcorKMEy2JQ1kng


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
