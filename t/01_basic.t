use Test::Base;
use Moose::Set qw(set);

plan tests => 1 * blocks;
filters { input => 'eval', expected => 'eval' };

run {
    my $block = shift;
    my $x = set( $block->input );
    is_deeply $x->elements, [ $block->expected ];
};

__END__

===
--- input
1, 2
--- expected
1, 2

===
--- input
qw(a b c)
--- expected
qw(a b c)
