package MooX::ClassAttribute;

use 5.008;
use strict;
use warnings;

BEGIN {
	$MooX::ClassAttribute::AUTHORITY = 'cpan:TOBYINK';
	$MooX::ClassAttribute::VERSION   = '0.001';
}

use Carp;
use Moo ();
use Moo::Role ();
use MooX::CaptainHook -all;

BEGIN { *ROLE = \%Role::Tiny::INFO }
our %ROLE;
BEGIN { *CLASS = \%Moo::MAKERS }
our %CLASS;

our %ATTRIBUTES;

sub import
{
	my $me     = shift;
	my $target = caller;
	
	my $install_tracked;
	{
		no warnings;
		if ($CLASS{$target})
		{
			$install_tracked = \&Moo::_install_tracked;
		}
		elsif ($ROLE{$target})
		{
			$install_tracked = \&Moo::Role::_install_tracked;
		}
		else
		{
			croak "MooX::ClassAttribute applied to a non-Moo package"
				. "(need: use Moo or use Moo::Role)";
		}
	}

	my $is_role = is_role($target);
	
	$install_tracked->(
		$target, class_has => sub
		{
			my ($proto, %spec) = @_;
			for my $name (ref $proto ? @$proto : $proto)
			{
				my $spec = +{ %spec }; # shallow clone
				$is_role
					? $me->_process_for_role($target, $name, $spec)
					: $me->_class_accessor_maker_for($target)->generate_method($target, $name, $spec);
				push @{$ATTRIBUTES{$target}||=[]}, $name, $spec;
			}
			return;
		},
	);
	
	$me->_setup_inflation($target);
}

sub _process_for_role
{
	my ($me, $target, $name, $spec) = @_;
	on_application {
		my ($applied_to) = @_;
		$me
			-> _class_accessor_maker_for($applied_to)
			-> generate_method($applied_to, $name, $spec);
	} $target;
	'Moo::Role'->_maybe_reset_handlemoose($target);
}

sub _class_accessor_maker_for
{
	my ($me, $target) = @_;
	$CLASS{$target}{class_accessor} ||= do {
		require Method::Generate::ClassAccessor;
		'Method::Generate::ClassAccessor'->new;
	};
}

my %did_setup;
sub _setup_inflation
{
	my ($me, $target) = @_;
	return if $did_setup{$target}++;
#	on_inflation
#		{ $me->_on_inflation($target, @_) }
#		$target;
}

my $warning;
sub _on_inflation
{
	my ($me, $target, $meta) = @_;
	
	eval { require MooseX::ClassAttribute } or do {
		carp <<WARNING unless $warning++; return;
***
*** MooX::ClassAttribute and Moose, but MooseX::ClassAttribute is not
*** available. It is strongly recommended that you install this module.
***
WARNING
	};
	
	require Moose::Util::MetaRole;
	if ( is_role($meta->name) )
	{
		$meta = Moose::Util::MetaRole::apply_metaroles(
			for             => $meta->name,
			role_metaroles  => {
				role                 => ['MooseX::ClassAttribute::Trait::Role'],
				application_to_class => ['MooseX::ClassAttribute::Trait::Application::ToClass'],
				application_to_role  => ['MooseX::ClassAttribute::Trait::Application::ToRole'],
			},
		);
	}
	else
	{
		$meta = Moose::Util::MetaRole::apply_metaroles(
			for             => $meta->name,
			class_metaroles => {
				class => ['MooseX::ClassAttribute::Trait::Class', 'MooseX::ClassAttribute::Hack']
			},
		);
	}
	
	my $attrs = $ATTRIBUTES{$target} || [];
	for (my $i = 0; $i < @$attrs; $i+=2)
	{
		my $name = $attrs->[$i+0];
		my $spec = $attrs->[$i+1];
		MooseX::ClassAttribute::class_has(
			$meta,
			$name,
			$me->_sanitize_spec($spec),
		);
	}
}

my %ok_options = map { ;$_=>1 } qw(
	is reader writer accessor clearer predicate handles
	required isa does coerce trigger
	default builder lazy_build lazy
	documentation
);

sub _sanitize_spec
{
	my ($me, $spec) = @_;
	my @return;
	for my $key (%$spec)
	{
		next unless $ok_options{$key};
		push @return, $key, $spec->{$key};
	}
	return (
		@return,
		definition_context => { package => __PACKAGE__ },
	);
}

{
	package MooseX::ClassAttribute::Hack;
	use Moo::Role;
	around _post_add_class_attribute => sub {
		my $orig = shift;
		my $self = shift;
		return if $self->definition_context->{package} eq 'MooseX::ClassAttribute';
		$self->$orig(@_);
	};
}

1;

__END__

=head1 NAME

MooX::ClassAttribute - declare class attributes Moose-style... but without Moose

=head1 SYNOPSIS

   {
      package Foo;
      use Moo;
      use MooX::ClassAttribute;
      class_has ua => (
         is      => 'rw',
         default => { LWP::UserAgent->new },
      );
   }
   
   my $r = Foo->ua->get("http://www.example.com/");

=head1 DESCRIPTION

This module adds support for class attributes to L<Moo>. Class attributes
are attributes whose values are not associated with any particular instance
of the class.

For example, the C<Person> class might have a class attribute "binomial_name";
its value "Homo sapiens" is not associated with any particular individual, but
the class as a whole.

   say Person->binomial_name;   # "Homo sapiens"
   my $bob = Person->new;
   say $bob->binomial_name;     # "Homo sapiens"
   
   my $alice = Person->new;
   $alice->binomial_name("H. sapiens");
   say $bob->binomial_name;     # "H. sapiens"

Class attributes may be defined in roles, however they cannot be called as
methods using the role package name. Instead the role must be composed with
a class; the class attributes will be installed into that class.

This module mostly tries to behave like L<MooseX::ClassAttribute>.

=head1 CAVEATS

=over

=item *

Overriding class attributes and their accessors in subclasses is not yet
supported. The implementation, and expected behaviour hasn't been figured
out yet.

=item *

When Moo classes are inflated to Moose classes, it would be nice to also
inflate MooX::ClassAttribute attributes to MooseX::ClassAttribute attributes,
however I have not had much luck with that yet.

Currently accessors installed by this module will just appear as plain old
methods in Moose's introspection API.

=back

=head1 BUGS

Please report any bugs to
L<http://rt.cpan.org/Dist/Display.html?Queue=MooX-ClassAttribute>.

=head1 SEE ALSO

L<Moo>,
L<MooseX::ClassAttribute>.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2012 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 DISCLAIMER OF WARRANTIES

THIS PACKAGE IS PROVIDED "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF
MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.

