# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'Perl5::Parse::MakeLog::Warnings' ); }

my $object = Perl5::Parse::MakeLog::Warnings->new ();
isa_ok ($object, 'Perl5::Parse::MakeLog::Warnings');


