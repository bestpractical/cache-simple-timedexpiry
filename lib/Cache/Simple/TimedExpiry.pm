# Tie::Hash::Expire::Dumb
package Cache::Simple::TimedExpiry;
use strict;

use vars qw/$VERSION/;

$VERSION = '0.20';

# 0 - expiration delay
# 1 - hash
# 2 - expiration queue

=head2 new

Set up a new cache object

=cut


sub new {
  bless [2,{},[]], "Cache::Simple::TimedExpiry";
}


=head2 expire_after SECONDS

Set the cache's expiry policy to expire entries after SECONDS seconds. Setting this changes the expiry policy for pre-existing cache entries and for new ones.


=cut

sub expire_after {
    my $self = shift;
    $self->[0] = shift if (@_);
    return ($self->[0]);

}


=head2 has_key KEY

Return true if the cache has an entry with the key KEY

=cut

sub has_key ($$) { # exists
  my ($self, $key) = @_;
  
  return 1 if  $key && exists $self->[1]->{$key};
  return 0;
}

=head2 fetch KEY

Return the cache entry with key KEY.
Returns undef if there is no such entry

=cut

sub fetch ($$) {
  my ($self,$key) = @_;

    $self->expire();
    unless ( $self->has_key($key)) {
          return undef;
     }

  return $self->[1]->{$key};

}

=head2 store KEY VALUE

Store VALUE in the cache with accessor KEY.  Expire it from the cache 
at or after EXPIRYTIME.

=cut

sub set ($$$) {
  my ($self,$key,$value) = @_;

  $self->expire();

  $self->[1]->{$key} = $value;

    push @{$self->[2]}, [ time, $key ];
}

sub expire ($) {
  my ($self) = @_;

  my $oldest_nonexpired_entry = (time - $self->[0]);
 

  return unless defined $self->[2]->[0]; # do we have an element in the array?


  return unless $self->[2]->[0]->[0] < $oldest_nonexpired_entry; # is it expired?

  while ( @{$self->[2]} && $self->[2]->[0]->[0] <$oldest_nonexpired_entry ) {
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
