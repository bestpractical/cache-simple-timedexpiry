use Test::More qw/no_plan/;

use_ok('Cache::Simple::TimedExpiry');

my $h = new Cache::Simple::TimedExpiry;

is ($h->expire_after(),2);
$h->expire_after(10);
is ($h->expire_after(),10);

is(ref($h), 'Cache::Simple::TimedExpiry');

$h->set( 'Temp' => 'Temporary');
sleep(8);
$h->set( 'Temp2' => 'Temporary');
is ($h->fetch('Temp'), 'Temporary');
is ($h->fetch('Temp2'), 'Temporary');
sleep(5);


is ($h->fetch('Temp2'), 'Temporary');
is ($h->fetch('Temp'), undef);

sleep(6);
is ($h->fetch('Temp2'), undef);

