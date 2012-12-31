package Method::Generate::Accessor::Classy;

use 5.008;
use strict;
use warnings;
no warnings qw( void once uninitialized numeric );

BEGIN {
	no warnings 'once';
	$Method::Generate::Accessor::Classy::AUTHORITY = 'cpan:TOBYINK';
	$Method::Generate::Accessor::Classy::VERSION   = '0.001';
}

use B 'perlstring';

use base qw(Method::Generate::Accessor);

sub generate_method
{
	my ($self, $into, $name, $spec, $quote_opts) = @_;
	local $Method::Generate::Accessor::CAN_HAZ_XS = 0; # sorry
	$spec->{_classy} ||= $into;
	my $r = $self->SUPER::generate_method($into, $name, $spec, $quote_opts);
	
	# Populate default value
	unless ($spec->{lazy})
	{
		my $storage = do {
			no strict 'refs';
			\%{"$spec->{_classy}\::__ClassAttributeValues"};
		};
		if (my $default = $spec->{default})
		{
			$storage->{$name} = $default->($into);
		}
		elsif (my $builder = $spec->{builder})
		{
			$storage->{$name} = $into->$builder;
		}
	}
	
	return $r;
}

sub _generate_simple_get
{
	my ($self, $me, $name, $spec) = @_;
	my $classy = $spec->{_classy};
	"\$$classy\::__ClassAttributeValues{${\perlstring $name}}";
}

sub _generate_core_set
{
	my ($self, $me, $name, $spec, $value) = @_;
	my $classy = $spec->{_classy};
	"\$$classy\::__ClassAttributeValues{${\perlstring $name}} = $value";
}

sub _generate_simple_has
{
	my ($self, $me, $name, $spec) = @_;
	my $classy = $spec->{_classy};
	"exists \$$classy\::__ClassAttributeValues{${\perlstring $name}}";
}

sub _generate_simple_clear
{
	my ($self, $me, $name, $spec) = @_;
	my $classy = $spec->{_classy};
	"delete \$$classy\::__ClassAttributeValues{${\perlstring $name}}";
}

1;

