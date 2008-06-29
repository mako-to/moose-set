package Moose::Set;

our $VERSION = '0.01';

use Moose;
use Sub::Exporter -setup => { exports => [qw/set/] };
use List::Util ();
use List::MoreUtils ();

use overload
    '""'   => \&say,
    '+='   => \&insert,
    '-='   => \&delete,
    '/='   => \&invert,
    '+'    => \&union,
    '*'    => \&intersection,
    '-'    => \&difference,
    '%'    => \&symmetric_difference,
    '/'    => \&unique,
    'neg'  => \&complement,
    '<=>'  => \&compare,
    'cmp'  => \&compare,
    '=='   => \&is_equal,
    'eq'   => \&is_equal,
    '!='   => \&is_disjoint,
    'ne'   => \&is_disjoint,
    '<'    => \&is_proper_subset,
    'lt'   => \&is_proper_subset,
    '>'    => \&is_proper_superset,
    'gt'   => \&is_proper_superset,
    '<='   => \&is_subset,
    'le'   => \&is_subset,
    '>='   => \&is_superset,
    'ge'   => \&is_superset,
    'bool' => \&size,
    '@{}'  => \&members,
    '&{}'  => sub {
        my $self = shift;
        require Data::Dumper;
        sub { warn Data::Dumper->Dump( [$self, @_ ] ) }
    },
    fallback => 1;

has elements => (
    is  => 'rw',
    isa => 'ArrayRef',
);

sub set (@) {
    __PACKAGE__->new( elements => \@_ );
}

sub members {
    my $self = shift;
    $self->elements;
}

sub unblessed {
    my $self = shift;
    @{ $self->elements };
}

sub universe {
    my $self = shift;
    my @results = List::MoreUtils::uniq $self->unblessed;
    $self->elements( \@results );
    $self;
}

sub copy {
    my $self = shift;
    $self->new( elements => $self->elements );
}

*dup = \&copy;

# Modifying Methods

sub insert {
    my ( $self, @elements ) = @_;
    my @results = $self->unblessed;
    $self->elements( [ @results, @elements ] );
    $self;
}

sub delete {
    my ( $self, @elements ) = @_;
    return unless @elements;

    my @results;
    for my $i ( $self->unblessed ) {
        push @results, $i unless grep { $_ =~ /^$i$/ } @elements;
    }
    $self->elements( \@results );
    $self;
}

sub invert {
    my ( $self, @elements ) = @_;
    $self->has_elements ? $self->insert(@elements) : $self->delete(@elements);
    $self;
}

sub clear {
    my $self = shift;
    $self->elements( [] );
    $self;
}

sub compact {
    my $self = shift;
    my @results = grep { defined } $self->unblessed;
    $self->elements( \@results );
    $self;
}

sub more_compact {
    my $self = shift;
    my @results = grep { defined and $_ } $self->unblessed;
    $self->elements( \@results );
    $self;
}

sub reverse {
    my $self = shift;
    my @results = reverse $self->unblessed;
    $self->elements( \@results );
    $self;
}

sub rotate {
    my $self = shift;
    my @results = List::Util::shuffle $self->unblessed;
    $self->elements( \@results );
    $self;
}

sub collect {
    my ( $self, $code ) = @_;
    my @results = map $code->(), $self->unblessed;
    $self->elements( \@results );
    $self;
}

*map = \&collect;

sub select {
    my ( $self, $code ) = @_;
    my @results = grep $code->(), $self->unblessed;
    $self->elements( \@results );
    $self;
}

*grep = \&select;

# Displaying Methods

sub say {
    my $self = shift;
    require Perl6::Say;
    Perl6::Say::say( $self->unblessed );
}

sub join {
    my ( $self, $delimiter ) = @_;
    $delimiter ||= ',';
    join $delimiter, $self->unblessed;
}

# Querying Methods

sub has_elements {
    my $self = shift;
    $self->unblessed ? 1 : 0;
}

sub is_null {
    my $self = shift;
    !$self->has_elements ? 1 : 0;
}

*is_empty = \&is_null;

sub size {
    my $self = shift;
    scalar $self->unblessed;
}

sub count {
    my ( $self, $element ) = @_;
    return scalar grep { !defined } $self->unblessed unless defined $element;
    scalar grep { /^$element$/ } $self->unblessed;
}

sub contains {
    my ( $self, $element ) = @_;
    ( grep { /^$element$/ } $self->unblessed ) ? 1 : 0;
}

*exists = \&contains;

sub at {
    my ( $self, $index ) = @_;
    $index ||= 0;
    $self->elements->[$index];
}

sub first {
    my $self = shift;
    $self->at(0);
}

sub last {
    my $self = shift;
    $self->at(-1);
}

sub reduce {
    my ( $self, $code ) = @_;
    List::Util::reduce sub { $code->( $a, $b ) }, $self->unblessed;
}

sub max {
    my $self = shift;
    List::Util::max $self->unblessed;
}

# Deriving Methods

sub union {
    my ( $this, $that ) = @_;
    my %union;
    $union{$_}++ for $this->unblessed, $that->unblessed;
    my @results = keys %union;
    $this->new( elements => \@results );
}

sub intersection {
    my ( $this, $that ) = @_;
    my @results = grep { $that->contains($_) } $this->unblessed;
    $this->new( elements => \@results );
}

sub difference {
    my ( $this, $that ) = @_;
    my @results = grep { !$that->contains($_) } $this->unblessed;
    $this->new( elements => \@results );
}

sub symmetric_difference {
    my ( $this, $that ) = @_;
    my @results = grep { !$this->contains($_) or !$that->contains($_) }
        $this->union($that)->unblessed;
    $this->new( elements => \@results );
}

sub unique {
    # XXX
}

sub complement {
    # XXX: 補集合
}

# Comparing Methods

sub is_equal {
    my ( $this, $that ) = @_;
    return 0 unless $this->size == $that->size;

    my ( %this_count, %that_count );
    $this_count{$_}++ for $this->unblessed;
    $that_count{$_}++ for $that->unblessed;

    for my $e ( keys %this_count ) {
        return 0 unless exists $that_count{$e};
        return 0 unless $this_count{$e} eq $that_count{$e};
    }
    return 1;
}

sub is_disjoint {
    my ( $this, $that ) = @_;
    !$this->is_equal($that) ? 1 : 0;
}

sub is_subset {
    my ( $this, $that ) = @_;
    ( $this->size == grep { $that->contains($_) } $this->unblessed ) ? 1 : 0;
}

sub is_proper_subset {
    my ( $this, $that ) = @_;
    $this->is_disjoint($that) and $this->is_subset($that);
}

sub is_superset {
    my ( $this, $that ) = @_;
    $that->is_subset($this);
}

sub is_proper_superset {
    my ( $this, $that ) = @_;
    $that->is_proper_subset($this);
}

sub compare {
    my ( $this, $that ) = @_;
    # XXX
#     return 'proper superset' if $this->is_proper_superset($that);
#     return 'proper subset'   if $this->is_proper_subset($that);
#     return 'disjoint'        if $this->is_disjoint($that);
#     return 'equal'           if $this->is_equal($that);
#     return 'superset'        if $this->is_superset($that);
#     return 'subset'          if $that->is_subset($that);
#     return 'proper intersect';
}

1;
__END__

=head1 NAME

Moose::Set -

=head1 SYNOPSIS

  use Moose::Set;

=head1 DESCRIPTION

Moose::Set is

=head1 AUTHOR

Makoto Miura E<lt>makoto at nanolia.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

=cut
