=head1 PURPOSE

Test C<class_has> in roles, with inflation to Moose.

Check introspection.

=head1 AUTHOR

Toby Inkster E<lt>tobyink@cpan.orgE<gt>.

=head1 COPYRIGHT AND LICENCE

This software is copyright (c) 2013 by Toby Inkster.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

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
is(WithFoo->foo, 42, 'WithFoo class attribute WORKS');

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

is(WithBar->bar, "WithBar XYZ", 'WithBar class attribute WORKS');

unless (eval { require MooseX::ClassAttribute })
{
	diag "no MooseX::ClassAttribute; no further tests";
	done_testing;
	exit;
}

my $_meta = sub {
	my $pkg = shift;
	require Class::MOP;
	Class::MOP::class_of($pkg);
};

$_->meta->name for qw( Foo WithFoo Bar WithBar );

subtest "Foo role meta" => sub {
	can_ok(Foo->$_meta, 'get_class_attribute');
	ok(Foo->$_meta->get_class_attribute('foo'));
	ok(not Foo->$_meta->get_class_attribute('foo')->has_default);
};

subtest "Bar role meta" => sub {
	can_ok(Bar->$_meta, 'get_class_attribute');
	ok(Bar->$_meta->get_class_attribute('bar'));
	ok(Bar->$_meta->get_class_attribute('bar')->has_default);
};

subtest "WithFoo class meta" => sub {
	can_ok(WithFoo->meta, 'get_class_attribute');
	ok(WithFoo->meta->get_class_attribute('foo'));
	ok(not WithFoo->meta->get_class_attribute('foo')->has_default);
};

subtest "WithBar class meta" => sub {
	can_ok(WithBar->meta, 'get_class_attribute');
	ok(WithBar->meta->get_class_attribute('bar'));
	ok(WithBar->meta->get_class_attribute('bar')->has_default);
};

done_testing;
