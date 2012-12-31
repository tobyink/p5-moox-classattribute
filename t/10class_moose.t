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
eval { require Moose } or plan skip_all => 'need Moose';
is(Foo->foo, 42);

{
	package Bar;
	use Moo;
	use MooX::ClassAttribute;
	class_has bar => ( is => 'rw', default => sub { "Elephant" } );
}

is(Bar->bar, "Elephant");

#unless (eval { require MooseX::ClassAttribute })
#{
#	diag "no MooseX::ClassAttribute; no further tests";
#	done_testing;
#	exit;
#}
#
#can_ok(Foo->meta, 'get_class_attribute');
#ok(Class::MOP::class_of('Foo')->get_class_attribute('foo'));
#ok(not Class::MOP::class_of('Foo')->get_class_attribute('foo')->has_default);
#
#can_ok(Bar->meta, 'get_class_attribute');
#ok(Bar->meta->get_class_attribute('bar'));
#ok(Bar->meta->get_class_attribute('bar')->has_default);

done_testing;
