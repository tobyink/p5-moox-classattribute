use 5.010;
use strict;
use warnings;

{
	package Local::Life;
	use Moo::Role;
	use MooX::ClassAttribute;
	class_has binomial_name => (is => 'rwp');
}

{
	package Local::Person;
	use Moo;
	with 'Local::Life';
	__PACKAGE__->_set_binomial_name('Homo sapiens');
	has name => (is => 'ro');
}

my $bob = Local::Person->new(name => 'Robert');
say $bob->name;
say $bob->binomial_name;
