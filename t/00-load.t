#!perl

use Test::More tests => 4;

BEGIN {
    use_ok('Crypt::Image')         || print "Bail out!";
    use_ok('Crypt::Image::Axis')   || print "Bail out!";
    use_ok('Crypt::Image::Util')   || print "Bail out!";
    use_ok('Crypt::Image::Params') || print "Bail out!";
}
