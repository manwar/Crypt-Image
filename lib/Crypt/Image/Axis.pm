package Crypt::Image::Axis;

use Data::Dumper;

use Mouse;
use Mouse::Util::TypeConstraints;

=head1 NAME

Crypt::Image::Axis - Coordinates of the image used in the Crypt::Image.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

has 'x' => (is => 'ro', isa => 'Num', required => 1);
has 'y' => (is => 'ro', isa => 'Num', required => 1);
has 'z' => (is => 'ro', isa => 'Num', required => 0);

=head1 DESCRIPTION

Used internally by Crypt::Image::Util module.

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-crypt-image at rt.cpan.org> or through the
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Crypt-Image>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Crypt::Image::Axis

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Crypt-Image>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Crypt-Image>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Crypt-Image>

=item * Search CPAN

L<http://search.cpan.org/dist/Crypt-Image/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2011 Mohammad S Anwar.

This  program  is  free  software; you can redistribute it and/or modify it under the terms of
either:  the  GNU  General Public License as published by the Free Software Foundation; or the
Artistic License.

See http://dev.perl.org/licenses/ for more information.

=head1 DISCLAIMER

This  program  is  distributed in the hope that it will be useful,  but  WITHOUT ANY WARRANTY;
without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut

__PACKAGE__->meta->make_immutable;
no Mouse; # Keywords are removed from the Crypt::Image::Axis package
no Mouse::Util::TypeConstraints;

1; # End of Crypt::Image::Axis
