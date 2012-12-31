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

diag "*** The Moose awakes!!" if $INC{'Moose.pm'};
done_testing;
