#!perl

use strict; use warnings;
use Crypt::Image;
use Test::More tests => 2;

eval { Crypt::Image->new() };
like($@, qr/Attribute \(file\) is required/);

eval { Crypt::Image->new(file => 't/key.pgn') };
like($@, qr/Attribute \(file\) does not pass the type constraint/);