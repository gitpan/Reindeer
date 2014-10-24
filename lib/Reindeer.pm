#
# This file is part of Reindeer
#
# This software is Copyright (c) 2011 by Chris Weyl.
#
# This is free software, licensed under:
#
#   The GNU Lesser General Public License, Version 2.1, February 1999
#
package Reindeer;
{
  $Reindeer::VERSION = '0.006';
}

# ABSTRACT: Moose with more antlers

use strict;
use warnings;

use Reindeer::Util;
use Moose::Exporter;
use Class::Load;

my (undef, undef, $init_meta) = Moose::Exporter->build_import_methods(
    install => [ qw{ import unimport } ],

    also          => [ 'Moose', Reindeer::Util::also_list() ],
    trait_aliases => [ Reindeer::Util::trait_aliases()      ],
    as_is         => [ Reindeer::Util::as_is()              ],
);

sub init_meta {
    my ($class, %options) = @_;
    my $for_class = $options{for_class};

    ### $for_class
    Moose->init_meta(for_class => $for_class);

    ### more properly in import()?
    Reindeer::Util->import_type_libraries({ -into => $for_class });
    Path::Class->export_to_level(1);
    Try::Tiny->export_to_level(1);
    MooseX::MarkAsMethods->import({ into => $for_class }, autoclean => 1);

    goto $init_meta if $init_meta;
}

!!42;



=pod

=encoding utf-8

=head1 NAME

Reindeer - Moose with more antlers

=head1 VERSION

version 0.006

=head1 SYNOPSIS

    # ta-da!
    use Reindeer;

    # ...is the same as:
    use Moose;
    use MooseX::MarkAsMethods autoclean => 1;
    use MooseX::AlwaysCoerce;
    use MooseX::AttributeShortcuts;
    # etc, etc, etc

=head1 DESCRIPTION

Like L<Moose>?  Use MooseX::* extensions?  Maybe some L<MooseX::Types>
libraries?  Hate that you have to use them in every.  Single.  Class.

Reindeer aims to resolve that :)  Reindeer _is_ Moose -- it's just Moose with
a number of the more useful/popular extensions already applied.  Reindeer is a
drop-in replacement for your "use Moose" line, that behaves in the exact same
way... Just with more pointy antlers.

=for Pod::Coverage     init_meta

=head1 EARLY RELEASE!

Be aware this package should be considered early release code.  While L<Moose>
and all our incorporated extensions have their own classifications (generally
GA or "stable"), this bundling is still under active development, and more
extensions, features and the like may still be added.

That said, my goal here is to increase functionality, not decrease it.

When this package hits GA / stable, I'll set the release to be >= 1.000.

=head1 NEW ATTRIBUTE OPTIONS

Unless specified here, all options defined by Moose::Meta::Attribute
and Class::MOP::Attribute remain unchanged.

For the following, "$name" should be read as the attribute name; and the
various prefixes should be read using the defaults

=head2 coerce => 0

Coercion is ENABLED by default; explicitly pass "coerce => 0" to disable.

(See also L<MooseX::AlwaysCoerce>.)

=head2 lazy_require => 1

The reader methods for all attributes with that option will throw an exception
unless a value for the attributes was provided earlier by a constructor
parameter or through a writer method.

(See also L<MooseX::LazyRequire>.)

=head2 is => 'rwp'

Specifing is => 'rwp' will cause the following options to be set:

    is     => 'ro'
    writer => "_set_$name"

=head2 is => 'lazy'

Specifing is => 'lazy' will cause the following options to be set:

    is       => 'ro'
    builder  => "_build_$name"
    init_arg => undef
    lazy     => 1

=head2 is => 'lazy', default => ...

Specifing is => 'lazy' and a default will cause the following options to be
set:

    is       => 'ro'
    init_arg => undef
    lazy     => 1

Note that this is the same as the prior option, but is included / phrased in
this way in a (successful, I hope) attempt at clarity.

=head2 builder => 1

Specifying builder => 1 will cause the following options to be set:

    builder => "_build_$name"

=head2 clearer => 1

Specifying clearer => 1 will cause the following options to be set:

    clearer => "clear_$name"

or, if your attribute name begins with an underscore:

    clearer => "_clear$name"

(that is, an attribute named "_foo" would get "_clear_foo")

=head2 predicate => 1

Specifying predicate => 1 will cause the following options to be set:

    predicate => "has_$name"

or, if your attribute name begins with an underscore:

    predicate => "_has$name"

(that is, an attribute named "_foo" would get "_has_foo")

=head2 trigger => 1

Specifying trigger => 1 will cause the attribute to be created with a trigger
that calls a named method in the class with the options passed to the trigger.
By default, the method name the trigger calls is the name of the attribute
prefixed with "_trigger_".

e.g., for an attribute named "foo" this would be equivalent to:

    trigger => sub { shift->_trigger_foo(@_) }

For an attribute named "_foo":

    trigger => sub { shift->_trigger__foo(@_) }

This naming scheme, in which the trigger is always private, is the same as the
builder naming scheme (just with a different prefix).

=head2 doc => ...

"doc" may now be used as a shorthand for "documentation".

=head1 NEW KEYWORDS (SUGAR)

In addition to all sugar provided by L<Moose> (e.g. has, with, extends), we
provide a couple new keywords.

=head2 class_has => (...)

Exactly like L<Moose/has>, but operates at the class (rather than instance)
level.

(See also L<MooseX::ClassAttribute>.)

=head2 default_for

default_for() is a shortcut to extend an attribute to give it a new default;
this default value may be any legal value for default options.

    # attribute bar defined elsewhere (e.g. superclass)
    default_for bar => 'new default';

... is the same as:

    has '+bar' => (default => 'new default');

=head2 abstract

abstract() allows one to declare a method dependency that must be satisfied by a
subclass before it is invoked, and before the subclass is made immutable.

    abstract 'method_name_that_must_be_satisfied';

=head2 requires

requires() is a synonym for abstract() and works in the way you'd expect.

=head1 AVAILABLE OPTIONAL ATTRIBUTE TRAITS

We make available the following trait aliases.  These traits are NOT
automatically applied to attributes, and can be used as:

    has foo => (traits => [ AutoDestruct ], ...);

=head2 AutoDestruct

    has foo => (
        traits  => [ AutoDestruct ],
        is      => 'ro',
        lazy    => 1,
        builder => 1,
        ttl     => 600,
    );

Allows for a "ttl" attribute option; this is the length of time (in seconds)
that a stored value is allowed to live; after that time the value is cleared
and the value rebuilt (given that the attribute is lazy and has a builder
defined).

See L<MooseX::AutoDestruct> for more information.

=head2 MultiInitArg

    has 'data' => (
        traits    => [ MultiInitArg ],
        is        => 'ro',
        isa       => 'Str',
        init_args => [qw(munge frobnicate)],
    );

This trait allows your attribute to be initialized with any one of multiple
arguments to new().

See L<MooseX::MultiInitArg> for more information.

=head2 UndefTolerant

=head1 INCLUDED EXTENSIONS

Reindeer includes the traits and sugar provided by the following extensions.
Everything their docs say they can do, you can do by default with Reindeer.

=head2 L<MooseX::AbstractMethod>

=head2 L<MooseX::AlwaysCoerce>

=head2 L<MooseX::AttributeShortcuts>

=head2 L<MooseX::ClassAttribute>

=head2 L<MooseX::LazyRequire>

=head2 L<MooseX::MarkAsMethods>

Note that this causes any overloads you've defined in your class/role to be
marked as methods, and L<namespace::autoclean> invoked.

=head2 L<MooseX::NewDefaults>

=head2 L<MooseX::StrictConstructor>

=head1 INCLUDED TYPE LIBRARIES

=head2 L<MooseX::Types::Moose>

=head2 L<MooseX::Types::Common::String>

=head2 L<MooseX::Types::Common::Numeric>

=head2 L<MooseX::Types::Path::Class>

=head2 L<MooseX::Types::Tied::Hash::IxHash>

=head1 OTHER

Non-Moose specific items made available to your class/role:

=head2 L<namespace::autoclean>

Technically, this is done by L<MooseX::MarkAsMethods>, but it's worth pointing
out here.  Any overloads present in your class/role are marked as methods
before autoclean is unleashed, so Everything Will Just Work as Expected.

=head2 L<Path::Class>

=head2 L<Try::Tiny>

=head1 CAVEAT

This author is applying his own assessment of "useful/popular extensions".
You may find yourself in agreement, or violent disagreement with his choices.
YMMV :)

=head1 SEE ALSO

Please see those modules/websites for more information related to this module.

=over 4

=item *

L<Moose>

=item *

L<All of the above referenced packages.|All of the above referenced packages.>

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

