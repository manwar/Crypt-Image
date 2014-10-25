use strict; use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Crypt::Image',
    AUTHOR        => q{Mohammad S Anwar <mohammad.anwar@yahoo.com>},
    VERSION_FROM  => 'lib/Crypt/Image.pm',
    ABSTRACT_FROM => 'lib/Crypt/Image.pm',
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean         => { FILES => 'Crypt-Image-*' },
    PREREQ_PM     => {
        'Test::More'   => 0,
        'Math::Random' => '0.71',
        'POSIX'        => '1.09',
        'GD::Image'    => '2.38',
        'Readonly'     => '1.03',
        'Mouse'        => '0.93',
    },
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
);
