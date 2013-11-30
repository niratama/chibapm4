use Mojo::Base -strict;

use Test::More;
use Test::Mojo;

my $t = Test::Mojo->new('ChibaPM4');
$t->get_ok('/')->status_is(302);
$t->get_ok('/index.html')->status_is(200);

done_testing();
