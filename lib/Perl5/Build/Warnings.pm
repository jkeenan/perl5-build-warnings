package Perl5::Build::Warnings;
use 5.14.0;
use warnings;
our $VERSION = '0.01';
use Carp;
use Data::Dump qw(dd pp);


sub new {
    my ($class, $params) = @_;
    croak "Argument to constructor must be hashref"
        unless (ref($params) && ref($params) eq "HASH");
    croak "Argument to constructor must contain 'file' element"
        unless exists $params->{file};
    croak "Cannot locate $params->{file}" unless -f $params->{file};

    my $data = {};
    while (my ($k,$v) = each %{$params}) {
        $data->{$k} = $params->{$k};
    }

    my $init = _parse_log_for_warnings($data);

    return bless $init, $class;
}

sub _parse_log_for_warnings {
    my $data = shift;
    my @warnings = ();
    my %warnings_groups = ();
    my $IN;
    open $IN, '<', $data->{file} or croak "Cannot open $data->{file}";
    while (my $l = <$IN>) {
        chomp $l;
        # op.c:5468:34: warning: argument ‘o’ might be clobbered by ‘longjmp’ or ‘vfork’ [-Wclobbered]
        next unless $l =~ m{^
            ([^:]+):
            (\d+):
            (\d+):\s+warning:\s+
            (.*?)\s+\[
            (-W.*)]$
        }x;
        my ($source_file, $line, $char, $warning_text, $warnings_group) =
            ($1, $2, $3, $4, $5);
        $warnings_groups{$warnings_group}++;
        push @warnings, {
            source      => $source_file,
            line        => $line,
            char        => $char,
            text        => $warning_text,
            group       => $warnings_group,
        };
    }
    $IN->close or croak "Unable to close handle after reading";
    $data->{warnings_groups} = \%warnings_groups;
    $data->{warnings} = \@warnings;
    return $data;
}

sub get_warnings_groups {
    my $self = shift;
    return $self->{warnings_groups};
}

sub report_warnings_groups {
    my $self = shift;
    for my $w (sort keys %{$self->{warnings_groups}}) {
        say sprintf "%-40s %3s" => $w, $self->{warnings_groups}{$w};
    }
}

sub get_warnings {
    my $self = shift;
    return $self->{warnings};
}

1;

__END__

=head1 NAME

Perl5::Build::Warnings - Parse make output for build-time warnings

=head1 SYNOPSIS

  use Perl5::Build::Warnings;
  blah blah blah


=head1 DESCRIPTION


=head1 USAGE


=head1 BUGS



=head1 SUPPORT



=head1 AUTHOR

    James E Keenan
    CPAN ID: JKEENAN
    jkeenan@cpan.org
    http://thenceforward.net/perl/modules/Perl5-Parse-MakeLog-Warnings

=head1 COPYRIGHT

This program is free software; you can redistribute
it and/or modify it under the same terms as Perl itself.

The full text of the license can be found in the
LICENSE file included with this module.


=head1 SEE ALSO

perl(1).

=cut

#################### main pod documentation end ###################


1;
# The preceding line will help the module return a true value

