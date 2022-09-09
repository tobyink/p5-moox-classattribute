package Local::Role;
use Moo::Role;
use MooX::CaptainHook qw(on_application);

our @output;

on_application {
	push @output, "@{$_[0]}";
};

1;
