use Test::More qw/no_plan/;

use_ok('Cache::Simple::TimedExpiry');

my $h = new Cache::Simple::TimedExpiry;

is (ref($h), 'Cache::Simple::TimedExpiry');
is ($h->has_key(), 0);
is ($h->has_key(""), 0);
is ($h->has_key(0), 0);

is ($h->expire_after(),2);
$h->expire_after(10);
is ($h->expire_after(),10);

$h->set( 'Temp' => 'Temporary');
sleep(8);
$h->set( 'Temp2' => 'Temporary2');
is ($h->fetch('Temp'), 'Temporary');
is ($h->fetch('Temp2'), 'Temporary2');
my @elements = sort $h->elements;
is_deeply (\@elements, ['Temp', 'Temp2']);
is ($h->has_key('Temp'), 1);
is ($h->has_key('Temp2'), 1);
sleep(5);


is ($h->fetch('Temp2'), 'Temporary2');
is ($h->fetch('Temp'), undef);
@elements = sort $h->elements;
is_deeply (\@elements, ['Temp2']);
is ($h->has_key('Temp2'), 1);
is ($h->has_key('Temp'), 0);

sleep(6);
is ($h->fetch('Temp2'), undef);
@elements = sort $h->elements;
is_deeply (\@elements, []);
is ($h->has_key('Temp2'), 0);
is ($h->has_key('Temp'), 0);
# empty

$h->expire_after(2);
is ($h->has_key(), 0);
$h->set( '' => 'WithEmptyKey');
$h->set( 0 => 'WithZeroKey');
is ($h->fetch(''), 'WithEmptyKey' );
is ($h->fetch(0), 'WithZeroKey' );
is ($h->has_key(''), 1);
is ($h->has_key(0), 1);
@elements = sort $h->elements;
is_deeply (\@elements, ['', 0]);
