package ChibaPM4::DB::RedisFactory;
use Mojo::Base -base;

use Mojo::Redis;
use Protocol::Redis::XS;

has 'config';

sub new_connection {
  my $self = shift;

  my $redis = Mojo::Redis->new(%{$self->config},
    protocol_redis => 'Protocol::Redis::XS',);
  $redis->connect;
  return $redis;
}

1;
__END__
vi: set sts=2 sw=2 et:

