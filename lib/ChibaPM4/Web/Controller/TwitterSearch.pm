package ChibaPM4::Web::Controller::TwitterSearch;
use Mojo::Base 'Mojolicious::Controller';

use Log::Minimal;

use Mojo::IOLoop;
use Mojo::Util qw(dumper);

use ChibaPM4::Model::Tweets;

use constant WEBSOCKET_TIMEOUT  => (300);
use constant PING_INTERVAL      => (60);

sub stream {
  my $self = shift;

  my $tweets = ChibaPM4::Model::Tweets->new(
    redis => $self->app->redis_factory->new_connection,
  );

  Mojo::IOLoop->stream($self->tx->connection)->timeout(WEBSOCKET_TIMEOUT);

  $tweets->on(message => sub {
      my ($tweets, $message) = @_;
      $self->send({json => $message});
    });
  $tweets->subscribe;

  my $ping_id = Mojo::IOLoop->recurring(
    (PING_INTERVAL) => sub {
      $self->send([1, 0, 0, 0, 9, time]);
    }
  );

  $self->on(
    finish => sub {
      my ($self, $code, $reason) = @_;
      $tweets->disconnect;
      undef $tweets;
      # PING処理を止める
      Mojo::IOLoop->remove($ping_id);

      debugf 'Socket closed %s %s', $code, $reason;
    }
  );
}

1;
__END__
vi:set sts=2 sw=2 et:

