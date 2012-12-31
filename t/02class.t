use strict;
use warnings;
use Test::More;

{
	package Foo;
	use Moo;
	use MooX::ClassAttribute;
	class_has foo => ( is => 'rw' );
}

Foo->foo(42);
is(Foo->foo, 42);

{
	package Bar;
	use Moo;
	use MooX::ClassAttribute;
	class_has bar => ( is => 'rw', default => sub { "Elephant" } );
}

is(Bar->bar, "Elephant");

diag "*** The Moose awakes!!" if $INC{'Moose.pm'};
done_testing;
