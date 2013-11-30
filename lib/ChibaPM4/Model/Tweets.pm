package ChibaPM4::Model::Tweets;
use Mojo::Base 'Mojo::EventEmitter';

use Log::Minimal;

use Mojo::JSON;
use Mojo::Util qw(dumper);

has 'json' => sub { Mojo::JSON->new };
has 'redis';

sub publish {
  my $self = shift;
  my $msg  = {@_};

  my $bytes = $self->json->encode($msg);

  $self->redis->publish('tweet_stream', $bytes);
}

sub subscribe {
  my $self = shift;

  $self->redis->subscribe(
    'tweet_stream' => sub {
      my ($redis, $data) = @_;
      my ($event, $channel, $message) = @$data;
      if (my $msg = $self->json->decode($message)) {
        $self->emit('message' => $msg);
      }
    }
  );
}

sub disconnect {
  my $self = shift;
  if ($self->redis) {
    $self->redis->disconnect;
    $self->redis(undef);
  }
}

sub DESTROY {
  my $self = shift;
  $self->disconnect;
}

1;
__END__
vi:set sts=2 sw=2 et:
