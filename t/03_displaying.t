use Test::Base;
use Moose::Set qw(set);

plan tests => 1 * blocks;
filters { elements => 'eval', delimiter => 'chomp', expected => 'chomp' };

run {
    my $block = shift;
    my $x     = set( $block->elements );

    is $x->join( $block->delimiter ), $block->expected;
};

__END__

===
--- elements
1, 2
--- delimiter
-
--- expected
1-2

===
--- elements
qw(a b c)
--- delimiter
-
--- expected
a-b-c
