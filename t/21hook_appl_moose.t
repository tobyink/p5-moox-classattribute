use strict;
use warnings;
use Test::More;

my @output;

{
	package Local::Role;
	use Moo::Role;
	use MooX::CaptainHook qw(on_application);
	
	on_application {
		push @output, "@_";
	};
}

eval q{
	package Local::OtherRole;
	use Moose::Role;
	with 'Local::Role'; # "Local::Role applied to Local::OtherRole"
	1;
} or plan skip_all => "requires Moose::Role: $@";

eval q{
	package Local::Class;
	use Moose;
	with 'Local::OtherRole'; # "Local::OtherRole applied to Local::Class"
	1;
} or plan skip_all => "requires Moose: $@";

is_deeply(
	\@output,
	[
		"Local::OtherRole Local::Role",
		"Local::Class Local::OtherRole",
	],
);

done_testing;
