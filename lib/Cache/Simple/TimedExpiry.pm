# Tie::Hash::Expire::Dumb
package Cache::Simple::TimedExpiry;
use strict;

use vars qw/$VERSION/;

$VERSION = '0.01';

# 0 - expiration delay
# 1 - hash
# 2 - expiration queue

=head2 new

Set up a new cache object

=cut


sub new {
  bless [2,{},[]], "Cache::Simple::TimedExpiry";
}

sub has_key ($$) { # exists
  my ($self, $key) = @_;
  
  return 1 if  $key && exists $self->[1]->{$key};
  return 0;
}

sub fetch ($$) {
  my ($self,$key) = @_;

    $self->expire();
    unless ( $self->has_key($key)) {
          return undef;
     }

  return $self->[1]->{$key};

}

=head2 store KEY VALUE EXPIRYTIME

Store VALUE in the cache with accessor KEY.  Expire it from the cache 
at or after EXPIRYTIME.

EXPIRYTIME is in seconds from now

Setting EXPIRYTIME to 0 means "Never expire"


=cut

sub set ($$$) {
  my ($self,$key,$value, $expiry) = @_;

  $self->expire();

  $self->[1]->{$key} = $value;
  if ($expiry) {

    push @{$self->[2]}, [ ($expiry+time), $key ];
    }
}

sub expire ($) {
  my ($self) = @_;

  my $now = time;
  return unless defined $self->[2]->[0]; # do we have an element in the array?
  return unless $self->[2]->[0]->[0] < $now; # is it expired?

  while ( @{$self->[2]} && $self->[2]->[0]->[0] < $now ) {
    my $key =  $self->[2]->[0]->[1];
    delete $self->[1]->{ $key } if exists $self->[1]->{$key};
    shift @{$self->[2]};
  }

}

sub elements ($) { # keys
  my ($self) = @_;

  $self->expire();
  return keys %{$self->[1]};

}

sub dump ($) {
  require Data::Dumper;
  print Data::Dumper::Dumper($_[0]);
}



=head1 NAME

Cache::Simple::TimedExpiry

=head2 EXAMPLE 

package main;
use strict;
use warnings;


my $h = new Cache::Simple::TimedExpiry;

$h->set( Forever => "Don't expire", 0);
do { $h->set($_,"Value of $_", 1); sleep 2;}  for
  qw(Have a nice day you little monkey);
$,=' ';

print $h->elements;
$h->dump;
sleep 4;
print $h->elements;
$h->dump;

print time;

=cut

1;
