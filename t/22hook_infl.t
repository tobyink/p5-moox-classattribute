use strict;
use warnings;
use Test::More;

my @inflated;

{
	package Foo;
	use Moo;
	use MooX::CaptainHook qw( on_inflation );
	on_inflation {
		push @inflated, sprintf("%s (%s)", $_->name, $_->isa('Moose::Meta::Role')?'Role':'Class');
	};
}

{
	package Boo;
	use Moo::Role;
	use MooX::CaptainHook qw( on_inflation );	
	on_inflation {
		push @inflated, sprintf("%s (%s)", $_->name, $_->isa('Moose::Meta::Role')?'Role':'Class');
	};
}

eval { require Moose } or plan skip_all => 'need Moose';

Class::MOP::class_of('Foo')->name;
Class::MOP::class_of('Boo')->name;

is_deeply(
	[ sort @inflated ],
	[
		"Boo (Role)",
		"Foo (Class)",
	],
) or diag explain \@inflated;

done_testing;
