use Test::Base;
use Moose::Set qw(set);

plan tests => 6 * blocks;
filters {
    map { $_ => 'eval' }
        qw(elements insert inserted delete deleted
           reversed collect collected select selected)
};

run {
    my $block = shift;
    my $x     = set( $block->elements );

    is_deeply $x->insert( $block->insert )->elements,   [ $block->inserted ];
    is_deeply $x->delete( $block->delete )->elements,   [ $block->deleted ];
    is_deeply $x->reverse->elements,                    [ $block->reversed ];
    is_deeply $x->collect( $block->collect )->elements, [ $block->collected ];
    is_deeply $x->select( $block->select )->elements,   [ $block->selected ];
    is_deeply $x->clear->elements,                      [];
};

__END__

===
--- elements
1, 2
--- insert
3, 4
--- inserted
1, 2, 3, 4
--- delete
1, 2
--- deleted
3, 4
--- reversed
4, 3
--- collect
sub { $_ * 10 }
--- collected
40, 30
--- select
sub { $_ == 30 }
--- selected
30

===
--- elements
qw(a b c)
--- insert
qw(x y z)
--- inserted
qw(a b c x y z)
--- delete
qw(c z)
--- deleted
qw(a b x y)
--- reversed
qw(y x b a)
--- collect
sub { $_ . 'x' }
--- collected
qw(yx xx bx ax)
--- select
sub { /y/ }
--- selected
qw(yx)
