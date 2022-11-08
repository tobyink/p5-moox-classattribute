use Test::More;

package
Quite::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Long::Name
{
    use Moo::Role;
    use MooX::ClassAttribute;
    class_has file_attr_class => (
        is       => 'ro',
    );

}

package Short  {
    use Moo;
    use Test::More;

    my @roles
      = (qw(
Quite::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Very::Long::Name
      ));


      ok( eval { Moo::Role->create_class_with_roles( __PACKAGE__, @roles ) }, 'create class' ) ;
}

done_testing;