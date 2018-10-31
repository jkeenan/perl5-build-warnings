# -*- perl -*-
# t/01-new.t - Check constructor

use 5.14.0;
use warnings;
use Test::More;
use Capture::Tiny ':all';
use Data::Dump qw(dd pp);

BEGIN { use_ok( 'Perl5::Build::Warnings' ); }

my ($self, $file, $rv, $stdout, @stdout, $wg, $xg);
my ($warnings_count, $expected_groups_count, $expected_single_warning_count);
my ($expected_total_warnings_count);

##### TESTS OF ERROR CONDITIONS #####

{
    local $@;
    eval { $self = Perl5::Build::Warnings->new(); };
    like($@, qr/Argument to constructor must be hashref/,
        "Got expected error message: no argument for new()");
}

{
    local $@;
    eval { $self = Perl5::Build::Warnings->new( 'file' => 'foo' ); };
    like($@, qr/Argument to constructor must be hashref/,
        "Got expected error message: argument for new() not a hashref");
}

{
    local $@;
    eval { $self = Perl5::Build::Warnings->new( [ 'file' => 'foo' ] ); };
    like($@, qr/Argument to constructor must be hashref/,
        "Got expected error message: argument for new() not a hashref");
}

{
    local $@;
    eval { $self = Perl5::Build::Warnings->new( { foo => 'bar' } ); };
    like($@, qr/Argument to constructor must contain 'file' element/,
        "Got expected error message: argument for new() must contain 'file' element");
}

{
    local $@;
    $file = 'bar';
    eval { $self = Perl5::Build::Warnings->new( { file => $file } ); };
    like($@, qr/Cannot locate $file/,
        "Got expected error message: cannot locate value for 'file' element");
}

##### TESTS OF VALID CODE #####

{
    note("regular (uncompressed) input");

    $file = "./t/data/make.g++-8-list-util-fallthrough.output.txt";
    $expected_groups_count = 7;
    $self = Perl5::Build::Warnings->new( { file => $file } );
    ok(defined $self, "Constructor returned defined object");
    isa_ok($self, 'Perl5::Build::Warnings');

    $stdout = capture_stdout {
        $self->report_warnings_groups;
    };
    like($stdout, qr/Wimplicit-fallthrough=\s+32/,
        "Reported implicit-fallthrough warning");

    @stdout = split /\n/ => $stdout;
    is(@stdout, $expected_groups_count,
        "report_warnings_groups(): $expected_groups_count types of warnings reported");
    my $w = $stdout[int(rand($expected_groups_count))];
    like($w, qr/^\s\s/, "report_warnings_groups() pretty prints with two leading whitespace");

    $wg = $self->get_warnings_groups;
    is(ref($wg), 'HASH', "get_warnings_groups() returned hashref");
    is(scalar keys %{$wg}, $expected_groups_count,
        "$expected_groups_count types of warnings found");
    $expected_single_warning_count = 32;
    is($wg->{'Wimplicit-fallthrough='}, $expected_single_warning_count,
        "Found $expected_single_warning_count instances of implicit-fallthrough warnings");
    $warnings_count = 0;
    map { $warnings_count += $_ } values %{$wg};
    $expected_total_warnings_count = 50;
    is($warnings_count, $expected_total_warnings_count,
        "Got total of $expected_total_warnings_count warnings");

    $xg = $self->get_warnings;
    is(ref($xg), 'ARRAY', "get_warnings() returned arrayref");
    is(scalar @{$xg}, $expected_total_warnings_count, "Got expected number of warnings");
}

{
    note("gzipped input");

    $file = "./t/data/linux.make.v5.29.3-26-g8da010579b.output.txt.gz";
    $expected_groups_count = 7;
    $self = Perl5::Build::Warnings->new( { file => $file } );
    ok(defined $self, "Constructor returned defined object");
    isa_ok($self, 'Perl5::Build::Warnings');

    $stdout = capture_stdout {
        $self->report_warnings_groups;
    };
    like($stdout, qr/Wimplicit-fallthrough=\s+33/,
        "Reported implicit-fallthrough warning");

    @stdout = split /\n/ => $stdout;
    is(@stdout, $expected_groups_count,
        "report_warnings_groups(): $expected_groups_count types of warnings reported");
    my $w = $stdout[int(rand($expected_groups_count))];
    like($w, qr/^\s\s/, "report_warnings_groups() pretty prints with two leading whitespace");

    $wg = $self->get_warnings_groups;
    is(ref($wg), 'HASH', "get_warnings_groups() returned hashref");
    is(scalar keys %{$wg}, $expected_groups_count,
        "$expected_groups_count types of warnings found");
    $expected_single_warning_count = 33;
    is($wg->{'Wimplicit-fallthrough='}, $expected_single_warning_count,
        "Found $expected_single_warning_count instances of implicit-fallthrough warnings");
    $warnings_count = 0;
    map { $warnings_count += $_ } values %{$wg};
    $expected_total_warnings_count = 51;
    is($warnings_count, $expected_total_warnings_count,
        "Got total of $expected_total_warnings_count warnings");

    $xg = $self->get_warnings;
    is(ref($xg), 'ARRAY', "get_warnings() returned arrayref");
    is(scalar @{$xg}, $expected_total_warnings_count, "Got expected number of warnings");
}

done_testing();
