use utf8;
package Topmed::DB::Schema::Result::Run;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Topmed::DB::Schema::Result::Run

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<runs>

=cut

__PACKAGE__->table("runs");

=head1 ACCESSORS

=head2 runid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 centerid

  data_type: 'integer'
  is_nullable: 1

=head2 dirname

  data_type: 'varchar'
  is_nullable: 0
  size: 64

=head2 status

  data_type: 'varchar'
  is_nullable: 1
  size: 256

=head2 bamcount

  data_type: 'integer'
  is_nullable: 1

=head2 xmlfound

  data_type: 'integer'
  default_value: 0
  is_nullable: 1

=head2 dateinit

  data_type: 'varchar'
  is_nullable: 1
  size: 12

=head2 datecomplete

  data_type: 'varchar'
  is_nullable: 1
  size: 10

=head2 comments

  data_type: 'text'
  is_nullable: 1

=cut

__PACKAGE__->add_columns(
  "runid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "centerid",
  { data_type => "integer", is_nullable => 1 },
  "dirname",
  { data_type => "varchar", is_nullable => 0, size => 64 },
  "status",
  { data_type => "varchar", is_nullable => 1, size => 256 },
  "bamcount",
  { data_type => "integer", is_nullable => 1 },
  "xmlfound",
  { data_type => "integer", default_value => 0, is_nullable => 1 },
  "dateinit",
  { data_type => "varchar", is_nullable => 1, size => 12 },
  "datecomplete",
  { data_type => "varchar", is_nullable => 1, size => 10 },
  "comments",
  { data_type => "text", is_nullable => 1 },
);

=head1 PRIMARY KEY

=over 4

=item * L</runid>

=back

=cut

__PACKAGE__->set_primary_key("runid");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-07-07 09:49:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:RSs5JHZgSLGxezscc9gwdA


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
