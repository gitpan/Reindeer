#
# This file is part of Reindeer
#
# This software is Copyright (c) 2011 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package Reindeer::Role;
{
  $Reindeer::Role::VERSION = '0.007';
}

# ABSTRACT: Reindeer in role form

use strict;
use warnings;

use Reindeer::Util;
use Moose::Exporter;

my (undef, undef, $init_meta) = Moose::Exporter->build_import_methods(
    install => [ qw{ import unimport } ],

    also          => [ 'Moose::Role', Reindeer::Util::also_list() ],
    trait_aliases => [ Reindeer::Util::trait_aliases()            ],
    as_is         => [ Reindeer::Util::as_is()                    ],
);

sub init_meta {
    my ($class, %options) = @_;
    my $for_class = $options{for_class};

    ### $for_class
    Moose::Role->init_meta(for_class => $for_class);
    Reindeer::Util->import_type_libraries({ -into => $for_class });
    Path::Class->export_to_level(1);
    Try::Tiny->export_to_level(1);
    MooseX::MarkAsMethods->import({ into => $for_class }, autoclean => 1);

    goto $init_meta if defined $init_meta;
}

!!42;



=pod

=encoding utf-8

=head1 NAME

Reindeer::Role - Reindeer in role form

=head1 VERSION

This document describes 0.007 of Reindeer::Role - released February 14, 2012 as part of Reindeer.

=head1 SYNOPSIS

    # ta-da!
    use Reindeer::Role;

=head1 DESCRIPTION

For now, see the L<Reindeer> docs for information about what meta extensions
are automatically applied.

=for Pod::Coverage     init_meta

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<Reindeer|Reindeer>

=item *

L<Moose::Role>

=back

=head1 SOURCE

The development version is on github at L<http://github.com/RsrchBoy/reindeer>
and may be cloned from L<git://github.com/RsrchBoy/reindeer.git>

=head1 BUGS

Please report any bugs or feature requests on the bugtracker website
https://github.com/RsrchBoy/reindeer/issues

When submitting a bug or request, please include a test-file or a
patch to an existing test-file that illustrates the bug or desired
feature.

=head1 AUTHOR

Chris Weyl <cweyl@alumni.drew.edu>

=head1 COPYRIGHT AND LICENSE

This software is Copyright (c) 2011 by Chris Weyl.

This is free software, licensed under:

  The GNU Lesser General Public License, Version 2.1, February 1999

=cut


__END__

