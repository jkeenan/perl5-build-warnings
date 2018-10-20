# -*- perl -*-
# t/02-warnings-groups.t - Check constructor

use 5.14.0;
use warnings;
use Test::More;
use Capture::Tiny ':all';
use Data::Dump qw( dd pp );

BEGIN { use_ok( 'Perl5::Parse::MakeLog::Warnings' ); }

my ($self, $file, $rv, $stdout, $wg, $xg);


{
    $file = "./t/data/make.g++-8-list-util-fallthrough.output.txt";
    $self = Perl5::Parse::MakeLog::Warnings->new( { 'file' => $file } );
    ok(defined $self, "Constructor returned defined object");
    isa_ok($self, 'Perl5::Parse::MakeLog::Warnings');

    $rv = $self->parse_log_for_warnings();
    ok($rv, "parse_log_for_warnings() returned true value");

    $stdout = capture_stdout {
        $self->report_warnings_groups;
    };
    #say STDERR $stdout;

    $wg = $self->get_warnings_groups;
    #dd($wg);
    is(ref($wg), 'HASH', "get_warnings_groups() returned hashref");
    is(scalar keys %{$wg}, 7, "7 types of warnings found");
    is($wg->{'-Wimplicit-fallthrough='}, 32, "Found 32 instances of implicit-fallthrough warnings");
    my $warnings_count = 0;
    map { $warnings_count += $_ } values %{$wg};
    is($warnings_count, 50, "Got total of 50 warnings");

    $xg = $self->get_warnings;
    is(ref($xg), 'ARRAY', "get_warnings() returned arrayref");
    is(scalar @{$xg}, $warnings_count, "Got expected number of warnings");

}

done_testing();

