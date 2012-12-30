use strict;
use warnings;
use Test::More;

use Method::Generate::Accessor::Classy;
use Sub::Defer;
use constant Gen => 'Method::Generate::Accessor::Classy';
use constant Pkg => 'Local::Test::Package';

my $generator = Gen->new;
isa_ok $generator, 'Method::Generate::Accessor';

$generator->generate_method(
	Pkg,
	foo => {
		is        => 'rw',
		writer    => 'set_foo',
		reader    => 'get_foo',
		accessor  => 'access_foo',
		predicate => 'has_foo',
		clearer   => 'clear_foo',
		handles   => [qw/ bar baz /],
	},
);

my @methods = qw/
	set_foo get_foo access_foo has_foo clear_foo
	_assert_foo bar baz
/;

can_ok Pkg, @methods;

Pkg->set_foo('42');
ok Pkg->has_foo;
is(Pkg->get_foo, 42);
Pkg->clear_foo;
ok not Pkg->has_foo;
Pkg->access_foo('Local::Bottoms');
is(Pkg->access_foo, 'Local::Bottoms');

ok not eval { Pkg->baz };
like $@, qr{^Can't locate object method "baz" via package "Local::Bottoms"};

done_testing;
