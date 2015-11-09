package DOM::Tiny::_Collection;

use strict;
use warnings;
use Carp 'croak';
use List::Util;
use Scalar::Util 'blessed';

our $VERSION = '0.001';

sub new {
  my $class = shift;
  return bless [@_], ref $class || $class;
}

sub TO_JSON { [@{shift()}] }

sub compact {
  my $self = shift;
  return $self->new(grep { defined && (ref || length) } @$self);
}

sub each {
  my ($self, $cb) = @_;
  return @$self unless $cb;
  my $i = 1;
  $_->$cb($i++) for @$self;
  return $self;
}

sub first {
  my ($self, $cb) = (shift, shift);
  return $self->[0] unless $cb;
  return List::Util::first { $_ =~ $cb } @$self if ref $cb eq 'Regexp';
  return List::Util::first { $_->$cb(@_) } @$self;
}

sub flatten { $_[0]->new(_flatten(@{$_[0]})) }

sub grep {
  my ($self, $cb) = (shift, shift);
  return $self->new(grep { $_ =~ $cb } @$self) if ref $cb eq 'Regexp';
  return $self->new(grep { $_->$cb(@_) } @$self);
}

sub join {
  join $_[1] // '', map {"$_"} @{$_[0]};
}

sub last { shift->[-1] }

sub map {
  my ($self, $cb) = (shift, shift);
  return $self->new(map { $_->$cb(@_) } @$self);
}

sub reduce {
  my $self = shift;
  @_ = (@_, @$self);
  goto &List::Util::reduce;
}

sub reverse { $_[0]->new(reverse @{$_[0]}) }

sub shuffle { $_[0]->new(List::Util::shuffle @{$_[0]}) }

sub size { scalar @{$_[0]} }

sub slice {
  my $self = shift;
  return $self->new(@$self[@_]);
}

sub sort {
  my ($self, $cb) = @_;

  return $self->new(sort @$self) unless $cb;

  my $caller = caller;
  no strict 'refs';
  my @sorted = sort {
    local (*{"${caller}::a"}, *{"${caller}::b"}) = (\$a, \$b);
    $a->$cb($b);
  } @$self;
  return $self->new(@sorted);
}

sub tap {
  my ($self, $cb) = (shift, shift);
  $_->$cb(@_) for $self;
  return $self;
}

sub to_array { [@{shift()}] }

sub uniq {
  my ($self, $cb) = (shift, shift);
  my %seen;
  return $self->new(grep { !$seen{$_->$cb(@_)}++ } @$self) if $cb;
  return $self->new(grep { !$seen{$_}++ } @$self);
}

sub _flatten {
  map { _ref($_) ? _flatten(@$_) : $_ } @_;
}

sub _ref { ref $_[0] eq 'ARRAY' || blessed $_[0] && $_[0]->isa(__PACKAGE__) }

1;

=for Pod::Coverage *EVERYTHING*

=cut