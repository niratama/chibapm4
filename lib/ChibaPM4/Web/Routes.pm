package ChibaPM4::Web::Routes;
use Mojo::Base -strict;

sub setup {
  my ($this, $r) = @_;

  $r->namespaces(['ChibaPM4::Web::Controller']);

  $r->get('/')->to('main#root');
  $r->websocket('/tw_search')->to('twitter_search#stream');

  return $r;
}

1;
__END__
vi:set sts=2 sw=2 et:


