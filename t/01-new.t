# -*- perl -*-
# t/01-new.t - Check constructor

use 5.14.0;
use warnings;
use Test::More;

BEGIN { use_ok( 'Perl5::Parse::MakeLog::Warnings' ); }

#my $self = Perl5::Parse::MakeLog::Warnings->new();

##### Test error conditions #####

my ($self, $file);

{
    local $@;
    eval { $self = Perl5::Parse::MakeLog::Warnings->new(); };
    like($@, qr/Argument to constructor must be hashref/,
        "Got expected error message: no argument for new()");
}

{
    local $@;
    eval { $self = Perl5::Parse::MakeLog::Warnings->new( 'file' => 'foo' ); };
    like($@, qr/Argument to constructor must be hashref/,
        "Got expected error message: argument for new() not a hashref");
}

{
    local $@;
    eval { $self = Perl5::Parse::MakeLog::Warnings->new( [ 'file' => 'foo' ] ); };
    like($@, qr/Argument to constructor must be hashref/,
        "Got expected error message: argument for new() not a hashref");
}

{
    local $@;
    eval { $self = Perl5::Parse::MakeLog::Warnings->new( { 'foo' => 'bar' } ); };
    like($@, qr/Argument to constructor must contain 'file' element/,
        "Got expected error message: argument for new() must contain 'file' element");
}

{
    local $@;
    $file = 'bar';
    eval { $self = Perl5::Parse::MakeLog::Warnings->new( { 'file' => $file } ); };
    like($@, qr/Cannot locate $file/,
        "Got expected error message: cannot locate value for 'file' element");
}

{
    $file = "./t/data/make.g++-8-list-util-fallthrough.output.txt";
    $self = Perl5::Parse::MakeLog::Warnings->new( { 'file' => $file } );
    ok(defined $self, "Constructor returned defined object");
    isa_ok($self, 'Perl5::Parse::MakeLog::Warnings');
}

done_testing();

