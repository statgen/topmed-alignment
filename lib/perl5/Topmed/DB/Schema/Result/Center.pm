use utf8;
package Topmed::DB::Schema::Result::Center;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

Topmed::DB::Schema::Result::Center

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<centers>

=cut

__PACKAGE__->table("centers");

=head1 ACCESSORS

=head2 centerid

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 centername

  data_type: 'varchar'
  is_nullable: 0
  size: 16

=cut

__PACKAGE__->add_columns(
  "centerid",
  { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
  "centername",
  { data_type => "varchar", is_nullable => 0, size => 16 },
);

=head1 PRIMARY KEY

=over 4

=item * L</centerid>

=back

=cut

__PACKAGE__->set_primary_key("centerid");


# Created by DBIx::Class::Schema::Loader v0.07043 @ 2015-07-07 09:49:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:8YjdmehQhk1IKK6uaMFSlQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
#
__PACKAGE__->has_many(
  runs =>
  'Topmed::DB::Schema::Result::Run',
  {'foreign.runid' => 'self.runid'}
);

1;
