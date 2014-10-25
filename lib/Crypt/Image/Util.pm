package Crypt::Image::Util;

use strict; use warnings;

use Data::Dumper;
use Math::Random;
use Crypt::Image::Axis;

=head1 NAME

Crypt::Image::Util - Helper for Crypt::Image module.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';

=head1 DESCRIPTION

Utility module for Crypt::Image. Methods can be accessed directly.

=head1 METHODS

=head2 cloneImage()

Clone the given image (object of type GD::Image) and returns the clone of type GD::Image.

=cut

sub cloneImage
{
    my $image = shift;
    return $image->clone;
}

=head2 saveImage()

Saves the given image data as given  file  name  of  the given type. The parameters are listed
below in sequence:

=over 3

=item * Filename with the complete path.

=item * Object of type GD::Image for the image.

=item * Type of the given image.

=back

=cut

sub saveImage
{
    my $file  = shift;
    my $image = shift;
    my $type  = shift;

    open(IMAGE, ">$file")
        || die("ERROR: Couldn't open file [$file] for writing. [$!]\n");
    binmode IMAGE;
    print IMAGE $image->png  if $type =~ /png/i;
    print IMAGE $image->gif  if $type =~ /gif/i;
    print IMAGE $image->jpeg if $type =~ /jpg/i;
    close(IMAGE);
}

=head2 moveDown()

Moves the given pixel down by given number.

=cut

sub moveDown
{
    my $this = shift;
    my $by   = shift;

    ($this < 128)?($this += $by):($this -= $by);
    return $this;
}

=head2 moveUp()

Moves the given pixel up by given number.

=cut

sub moveUp
{
    my $this = shift;
    my $by   = shift;

    ($this >= 128)?($this -= $by):($this += $by);
    return $this;
}

=head2 getColor()

Returns the color index for the given R, G and B.

=cut

sub getColor
{
    my $r = shift;
    my $g = shift;
    my $b = shift;

    my $image = GD::Image->new();
    return $image->colorAllocate($r, $g, $b);
}

=head2 splitInTwo()

Splits the given point into X,Y coordinates & returns an object of type Crypt::Image::Axis.

=cut

sub splitInTwo
{
    my $a = shift;
    my $r = int(random_uniform() * $a);
    $a -= $r;
    return Crypt::Image::Axis->new(x => $a, y => $r);
}

=head2 splitInThree()

Splits the given point into X,Y,Z coordinates & returns an object of type Crypt::Image::Axis.

=cut

sub splitInThree
{
    my $a = shift;
    my $z = 0;
    my $r = int(random_uniform() * $a);
    $a -= $r;
    if ($a > $r)
    {
        $z = int(random_uniform() * $a);
        $a -= $z;
    }
    else
    {
        $z = int(random_uniform() * $r);
        $r -= $z;
    }

    return Crypt::Image::Axis->new(x => $a, y => $r, z => $z);
}

=head2 differenceInAxis()

Returns the absolute difference in the R, G and B of the given key and cloned  images at X & Y
coordinates. The parameters are listed below in sequence:

=over 4

=item * Object of type GD::Image for key image.

=item * Object of type GD::Image for new image.

=item * X coordinate.

=item * Y coordinate.

=back

=cut

sub differenceInAxis
{
    my $k = shift;
    my $c = shift;
    my $x = shift;
    my $y = shift;

    my ($k_r, $k_g, $k_b) = Crypt::Image::Util::getPixelColorRGB($k, $x, $y);
    my ($c_r, $c_g, $c_b) = Crypt::Image::Util::getPixelColorRGB($c, $x, $y);

    return (abs($k_r-$c_r), abs($k_g-$c_g), abs($k_b-$c_b));
}

=head2 getPixelColorRGB()

Returns the R, G, B of the given image at the given X,Y coordinates. The parameters are listed
below in sequence:

=over 3

=item * Object of type GD::Image for the image.

=item * X coordinate.

=item * Y coordinate.

=back

=cut

sub getPixelColorRGB
{
    my $image = shift;
    my $x = shift;
    my $y = shift;

    my $index = $image->getPixel($x, $y);
    my ($r, $g, $b) = $image->rgb($index);
    return ($r, $g, $b);
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-crypt-image at rt.cpan.org> or through the
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Crypt-Image>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Crypt::Image::Util

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

1; # End of Crypt::Image::Util
