use Test::More qw/no_plan/;

use_ok('Cache::Simple::TimedExpiry');

my $h = new Cache::Simple::TimedExpiry;

is(ref($h), 'Cache::Simple::TimedExpiry');

$h->set( Forever => "Don't expire", 0);

is ($h->fetch('Forever'), "Don't expire");

$h->set( 'Temp' => 'Temporary', 2);
;
is ($h->fetch('Temp'), 'Temporary');

sleep 3;

is ($h->fetch('Temp'), undef);

is ($h->fetch('Forever'), "Don't expire");

