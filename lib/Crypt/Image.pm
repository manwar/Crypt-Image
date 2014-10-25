package Crypt::Image;

use Readonly;
use Data::Dumper;

use Mouse;
use GD::Image;
use Math::Random;
use POSIX qw/floor/;
use Crypt::Image::Util;
use Mouse::Util::TypeConstraints;

=head1 NAME

Crypt::Image - Interface to hide text into an image.

=head1 VERSION

Version 0.04

=cut

our $VERSION = '0.04';
Readonly my $INTENSITY => 30;
Readonly my $TYPE => {
    'png' => 1,
    #'gif' => 1,
    #'jpg' => 1
};

=head1 DESCRIPTION

It requires key image and a text message to start with. The text message is scattered  through
out the image and gaps are filled with random trash. RGB is used to hide the text message well
from any algorithm that searches for similarities between 2 or more images which are generated
by the same key. The UTF char code is randomly distributed between the R, G  and B, which then
gets added/substracted from the original RGB. So even if the same key image is used to encrypt
the same text, it will look different from previously encrypted images and  actual data pixels
are unrecognizable from trash data, which also changes randomly every time.

=cut

type 'FilePath' => where { -f $_ };
type 'FileType' => where { exists $TYPE->{lc($_)} };
has 'width'  => (is => 'ro', isa => 'Num',      required => 0);
has 'height' => (is => 'ro', isa => 'Num',      required => 0);
has 'file'   => (is => 'ro', isa => 'FilePath', required => 1);
has 'type'   => (is => 'ro', isa => 'FileType', required => 0, default => 'png');
has 'bytes'  => (is => 'rw', isa => 'Num',      required => 0);
has 'countc' => (is => 'rw', isa => 'Num',      default  => 0);

=head1 CONSTRUCTOR

The constructor takes at the least the location key image, currently only supports PNG format.
Make sure your key image is not TOO BIG. Please  refer  to the image key.png supplied with the
package tar ball to give you a start.

    use strict; use warnings;
    use Crypt::Image;

    my $crypter = Crypt::Image->new(file => 'your_key_image.png');

=cut

sub BUILD
{
    my $self = shift;
    $self->{key}    = GD::Image->new($self->{file});
    $self->{width}  = $self->{key}->width;
    $self->{height} = $self->{key}->height;
    $self->{bytes}  = ($self->{width} * $self->{height}) - 2;
    GD::Image->trueColor(1);
}

=head1 METHODS

=head2 encrypt()

Encrypts the key image (of type PNG currently) with the given text &  save it as the new image
by the given file name. The  length  of  the given text depends on height and width of the key
image given in the constructor. It should not be longer than (width*height)-2.

    use strict; use warnings;
    use Crypt::Image;

    my $crypter = Crypt::Image->new(file => 'your_key_image.png');
    $crypter->encrypt('Hello World', 'your_new_encrypted_image.png');

=cut

sub encrypt
{
    my $self = shift;
    my $text = shift;
    my $file = shift;
    die("ERROR: Encryption text is missing.\n") unless defined $text;
    die("ERROR: Decrypted file name is missing.\n") unless defined $file;
    die("ERROR: Encryption text is too long.\n") if ($self->{bytes} < length($text));

    my ($width, $height, $allowed, $count);
    $self->{copy} = Crypt::Image::Util::cloneImage($self->{key});
    $allowed = int(floor($self->{bytes}/length($text)));
    $self->_encryptAllowed($allowed, 1, 1);
    $self->{countc} = 0;
    $count = 0;

    foreach $width (0..$self->{width}-1)
    {
        foreach $height (0..$self->{height}-1)
        {
            unless (($width == 1) && ($height == 1))
            {
                $count++;
                if ($count == $allowed)
                {
                    $self->_encrypt($width, $height, $self->_next($text));
                    $count = 0;
                }
                else
                {
                    $self->_encrypt($width, $height, 0);
                }
            }
        }
    }
    Crypt::Image::Util::saveImage($file, $self->{copy}, $self->{type});
}

=head2 decrypt()

Decrypts the given encrypted image and returns the hidden text.

    use strict; use warnings;
    use Crypt::Image;

    my $crypter = Crypt::Image->new(file => 'your_key_image.png');
    $crypter->encrypt('Hello World', 'your_new_encrypted_image.png');
    print "Text: [" . $crypter->decrypt('your_new_encrypted_image.png') . "]\n";

=cut

sub decrypt
{
    my $self = shift;
    my $file = shift;
    die("ERROR: Encrypted file missing.\n") unless defined $file;
    die("ERROR: Encrypted file [$file] not found.\n") unless (-f $file);

    my ($allowed, $count, $text, $width, $height);

    $self->{copy} = GD::Image->new($file);
    $allowed = $self->_decryptAllowed(1, 1);
    $count   = 0;
    $text    = '';

    foreach $width (0..$self->{width}-1)
    {
        foreach $height (0..$self->{height}-1)
        {
            unless (($width == 1) && ($height == 1))
            {
                $count++;
                if ($count == $allowed)
                {
                    $text .= $self->_decrypt($width, $height);
                    $count = 0;
                }
            }
        }
    }
    return $text;
}

sub _encrypt
{
    my $self = shift;
    my $x    = shift;
    my $y    = shift;
    my $a    = shift;

    my ($r, $g, $b, $i, $axis);
    ($r,$g,$b) = Crypt::Image::Util::getPixelColorRGB($self->{key}, $x, $y);
    if ($a == 0)
    {
        $i = int(random_uniform() * $INTENSITY);
        $b = Crypt::Image::Util::moveUp($b, $i);
        $i = int(random_uniform() * $INTENSITY);
        $g = Crypt::Image::Util::moveUp($g, $i);
        $i = int(random_uniform() * $INTENSITY);
        $r = Crypt::Image::Util::moveUp($r, $i);
    }
    else
    {
        $axis = Crypt::Image::Util::splitInThree($a);
        $b = Crypt::Image::Util::moveUp($b, $axis->x);
        $g = Crypt::Image::Util::moveUp($g, $axis->y);
        $r = Crypt::Image::Util::moveUp($r, $axis->z);
    }

    $self->{copy}->setPixel($x, $y, Crypt::Image::Util::getColor($r, $g, $b));
}

sub _decrypt
{
    my $self = shift;
    my $x    = shift;
    my $y    = shift;

    my ($r, $g, $b) = Crypt::Image::Util::differenceInAxis($self->{key}, $self->{copy}, $x, $y);

    return chr($r+$g+$b);
}

sub _encryptAllowed
{
    my $self    = shift;
    my $allowed = shift;
    my $x       = shift;
    my $y       = shift;

    my ($r, $g, $b, $axis, $count);
    $count = 0;
    ($r,$g,$b) = Crypt::Image::Util::getPixelColorRGB($self->{key}, $x, $y);

    while ($allowed > 127)
    {
        $count++;
        $allowed -= 127;
    }

    if ($count > 0)
    {
        $axis = Crypt::Image::Util::splitInTwo($count);
        $r    = Crypt::Image::Util::moveDown($r, $axis->x);
        $g    = Crypt::Image::Util::moveDown($g, $axis->y);
    }

    $b = Crypt::Image::Util::moveDown($b, $allowed)
        if ($allowed <= 127);

    $self->{copy}->setPixel($x, $y, Crypt::Image::Util::getColor($r, $g, $b));
}

sub _decryptAllowed
{
    my $self = shift;
    my $x    = shift;
    my $y    = shift;

    my ($r, $g, $b) = Crypt::Image::Util::differenceInAxis($self->{key}, $self->{copy}, $x, $y);
    return (($r*127)+($g*127)+$b);
}

sub _next
{
    my $self = shift;
    my $text = shift;

    my $a = 0;
    if (length($text) > $self->{countc})
    {
        $a = ord(substr($text, $self->{countc}, 1));
        $self->{countc}++;
    }
    return $a;
}

=head1 AUTHOR

Mohammad S Anwar, C<< <mohammad.anwar at yahoo.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-crypt-image at rt.cpan.org> or through the
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Crypt-Image>.  I will be
notified, and then you'll automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Crypt::Image

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

=head1 ACKNOWLEDGEMENT

Joonas Vali, author of the blog L<http://forum.codecall.net/classes-code-snippets/18135-java-encrypt-text-into-image.html>
gave me the idea for this module.

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
no Mouse; # Keywords are removed from the Crypt::Image package
no Mouse::Util::TypeConstraints;

1; # End of Crypt::Image
