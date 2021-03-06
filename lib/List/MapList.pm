
package List::MapList;

use strict;
use warnings;

use base qw(Exporter);
our @EXPORT = qw(mapcycle maplist); 

our $VERSION = sprintf "%d.%03d", q$Revision: 1.4 $ =~ /(\d+)/g;

=head1 NAME

List::MapList -- map lists through a list of subs, not just one

=head1 SYNOPSIS

Contrived heterogenous transform

 use List::MapList

 my $code = [
   sub { $_ + 1 },
   sub { $_ + 2 },
   sub { $_ + 3 },
   sub { $_ + 4 }
 ];

 my @mapped = maplist( $code, qw(1 2 3 4 5 6 7 8 9));

 # @mapped is qw(2 4 6 8 6 8 10 12 13)

Ultra-secure partial rot13:

 my $rotsome = [
   sub { tr/a-zA-Z/n-za-mN-ZA-M/ },
   sub { tr/a-zA-Z/n-za-mN-ZA-M/ },
   sub { $_ },
 ];

 my @chars = split //, "Too many secrets.";
 mapcycle($rotsome, @chars);
 my $cyphertext = join //, @chars;

=head1 DESCRIPTION

List::MapList provides methods to map a list through a list of transformations,
instead of just one.  The transformations are not chained together on each
element; only one is used, alternating sequentially.

Here's a contrived example: given the transformations C<{ $_ = 0 }> and C<{ $_
= 1 }>, the list C<(1, 2, 3, "Good morning", undef)> would become C<(0, 1, 0, 1,
0)> or, without cycling, C<(0, 1)>.;

(I use this code to process a part number in which each digit maps to a set of
product attributes.)

=head1 FUNCTIONS

=over

=item C<< maplist($coderefs, LIST) >>

This routine acts much like a normal C<map>, but uses the list of code
references in C<$coderefs> in parallel with the list members.  First first code
reference is used for the first list member, the next for the second, and so
on.  Once the last code reference has been used, all further elements will be
mapped to C<()>.

=cut

sub maplist {
	my ($subs, $current) = (shift, 0);
	my $code = sub { $subs->[$current++] || sub { () }; };
	map $code->()->(), @_;
}

=item C<< mapcycle($coderefs, LIST) >>

This routine is identical to C<maplist>, but will cycle through the passed
coderefs over and over as needed.

=cut

sub mapcycle {
	my ($subs, $current) = (shift, 0);
	my $code = sub { $subs->[$current++ % @$subs]; };
	map $code->()->(), @_;
}

=back

=head1 TODO

...nothing?

=head1 AUTHORS

Ricardo SIGNES E<lt>rjbs@iqep.comE<gt>

=head1 COPYRIGHT

This code is Copyright 2004, Ricardo SIGNES.  It is free software, available
under the same terms as Perl itself.

=cut

1;
