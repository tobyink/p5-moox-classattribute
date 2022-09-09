=head1 PURPOSE

Test C<on_application> hook from L<MooX::CaptainHook>.

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

use lib './t/lib';

use Local::Class;
is_deeply(
	\@Local::Role::output,
	[
		"Local::Class Local::Role",
	],
);


done_testing;
