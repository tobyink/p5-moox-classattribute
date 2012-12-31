use strict;
use warnings;
use Test::More;

{
	package Foo;
	use Moo::Role;
	use MooX::ClassAttribute;
	class_has foo => ( is => 'rw' );
}

{
	package WithFoo;
	use Moo;
	with 'Foo';
}

WithFoo->foo(42);
eval { require Moose } or plan skip_all => 'need Moose';
is(WithFoo->foo, 42);

{
	package Bar;
	use Moo::Role;
	use MooX::ClassAttribute;
	class_has bar => ( is => 'rw', default => sub { "$_[0] XYZ" } );
}

{
	package WithBar;
	use Moo;
	with 'Bar';
}

is(WithBar->bar, "WithBar XYZ");

#unless (eval { require MooseX::ClassAttribute })
#{
#	diag "no MooseX::ClassAttribute; no further tests";
#	done_testing;
#	exit;
#}

done_testing;
