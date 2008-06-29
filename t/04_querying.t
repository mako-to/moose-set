use Test::Base;
use Moose::Set qw(set);

plan tests => 8 * blocks;
filters {
    elements => 'eval',
    map { $_ => 'chomp' } qw(size count counted contains first last at ated)
};

run {
    my $block = shift;
    my $x     = set( $block->elements );

    is $x->has_elements, 1;
    is !$x->is_null, 1;
    is $x->size, $block->size;
    is $x->count( $block->count ), $block->counted;
    is $x->contains( $block->contains ), 1;
    is $x->first, $block->first;
    is $x->last, $block->last;
    is $x->at( $block->at ), $block->ated;
};

__END__

===
--- elements
1, 2, 1
--- size
3
--- count
2
--- counted
1
--- contains
1
--- first
1
--- last
1
--- at
1
--- ated
2

===
--- elements
qw(a b c b)
--- size
4
--- count
b
--- counted
2
--- contains
c
--- first
a
--- last
b
--- at
2
--- ated
c
