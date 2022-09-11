use 5.008;
use strict;
use warnings;

package MooX::CaptainHook;

# This is just a wrapper for Role::Hooks now.
#
use Role::Hooks 0.005;
use Exporter::Shiny qw/ on_application on_inflation is_role /;

BEGIN {
	no warnings 'once';
	$MooX::CaptainHook::AUTHORITY = 'cpan:TOBYINK';
	$MooX::CaptainHook::VERSION   = '0.011';
}

sub is_role {
	!! 'Role::Hooks'->is_role( pop );
}

sub on_inflation (&;$) {
	my $callback = shift;
	my $target   = @_ ? shift : caller;
	'Role::Hooks'->after_inflate( $target, sub {
		my $package = shift;
		my $meta = eval { $package->meta };
		local $_ = $meta;
		$callback->( [ $meta ] );
	} );
}

sub on_application (&;$) {
	my $callback = shift;
	my $target   = @_ ? shift : caller;
	is_role( $target ) or return;
	'Role::Hooks'->before_apply( $target, sub {
		my ( $role, $package ) = @_;
		local $_ = $package;
		$callback->( [ $package, $role ] );
	} );
}

1;