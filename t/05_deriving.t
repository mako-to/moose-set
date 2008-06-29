use Test::Base;
use Moose::Set qw(set);

plan tests => 8 * blocks;
filters {
    map { $_ => 'eval' }
        qw(x y sort union intersection difference symmetric_difference)
};

run {
    my $block = shift;
    my $x     = set( $block->x );
    my $y     = set( $block->y );

    my @result = ();
    @result = sort { $block->sort->( $a, $b ) } $x->union($y)->unblessed;
    is_deeply \@result, [ $block->union ];

    @result = ();
    @result = sort { $block->sort->( $a, $b ) } @{ $x + $y };
    is_deeply \@result, [ $block->union ];

    @result = ();
    @result = sort { $block->sort->( $a, $b ) } $x->intersection($y)->unblessed;
    is_deeply \@result, [ $block->intersection ];

    @result = ();
    @result = sort { $block->sort->( $a, $b ) } @{ $x * $y };
    is_deeply \@result, [ $block->intersection ];

    @result = ();
    @result = $x->difference($y)->unblessed;
    is_deeply \@result, [ $block->difference ];

    @result = ();
    @result = @{ $x - $y };
    is_deeply \@result, [ $block->difference ];

    @result = ();
    @result = sort { $block->sort->( $a, $b ) } $x->symmetric_difference($y)->unblessed;
    $block->symmetric_difference;
    is_deeply \@result, [ $block->symmetric_difference ];

    @result = ();
    @result = sort { $block->sort->( $a, $b ) }  @{ $x % $y };
    is_deeply \@result, [ $block->symmetric_difference ];
};

__END__

===
--- x
1, 2, 3, 4, 5
--- y
4, 5, 6, 7, 8
--- sort
sub { $_[0] <=> $_[1] }
--- union
1 .. 8
--- intersection
4, 5
--- difference
1, 2, 3
--- symmetric_difference
1, 2, 3, 6, 7, 8

===
--- x
qw(a b c d e)
--- y
qw(c d e f g)
--- sort
sub { $_[0] cmp $_[1] }
--- union
'a' .. 'g'
--- intersection
'c' .. 'e'
--- difference
qw(a b)
--- symmetric_difference
qw(a b f g)
