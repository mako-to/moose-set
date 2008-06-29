use Test::Base;
use Moose::Set qw(set);

plan tests => 12 * blocks;
filters {
    ( map { $_ => 'eval' } qw(x y) ),
    ( map { $_ => 'chomp' }
          qw(is_equal is_disjoint is_subset is_proper_subset is_superset is_proper_superset) ),
};

run {
    my $block = shift;
    my $x     = set( $block->x );
    my $y     = set( $block->y );

    is $x->is_equal($y), $block->is_equal;
    is $x == $y, $block->is_equal;

    is $x->is_disjoint($y), $block->is_disjoint;
    is $x != $y, $block->is_disjoint;

    is $x->is_subset($y), $block->is_subset;
    is $x <= $y, $block->is_subset;

    is $x->is_proper_subset($y), $block->is_proper_subset;
    is $x < $y, $block->is_proper_subset;

    is $x->is_superset($y), $block->is_superset;
    is $x >= $y, $block->is_superset;

    is $x->is_proper_superset($y), $block->is_proper_superset;
    is $x > $y, $block->is_proper_superset;
};

__END__

===
--- x
1, 2, 3, 4, 5
--- y
4, 5, 6, 7, 8
--- is_equal
0
--- is_disjoint
1
--- is_subset
0
--- is_proper_subset
0
--- is_superset
0
--- is_proper_superset
0

===
--- x
qw(a b c d e)
--- y
qw(c d e f g)
--- is_equal
0
--- is_disjoint
1
--- is_subset
0
--- is_proper_subset
0
--- is_superset
0
--- is_proper_superset
0

===
--- x
100 .. 200
--- y
100 .. 200
--- is_equal
1
--- is_disjoint
0
--- is_subset
1
--- is_proper_subset
0
--- is_superset
1
--- is_proper_superset
0

===
--- x
500 .. 700
--- y
500 .. 701
--- is_equal
0
--- is_disjoint
1
--- is_subset
1
--- is_proper_subset
1
--- is_superset
0
--- is_proper_superset
0

===
--- x
1000 .. 1500
--- y
1000 .. 1499
--- is_equal
0
--- is_disjoint
1
--- is_subset
0
--- is_proper_subset
0
--- is_superset
1
--- is_proper_superset
1
