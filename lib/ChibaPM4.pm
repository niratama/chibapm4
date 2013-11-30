package ChibaPM4;
use Mojo::Base 'Mojolicious';

use Config::Pit;

use ChibaPM4::DB::RedisFactory;
use ChibaPM4::Web::Routes;

use ChibaPM4::TwitterStream;

has 'redis_factory';
has 'stream';
has 'moniker' => 'chiba_pm4';

sub startup {
  my $self = shift;

  $self->plugin('log_warn');
  $self->plugin('log_minimal', {
      autodump => 1,
    });

  # 設定ファイルの読み込み
  my $config_file = 'conf/' . $self->moniker . '.conf';
  my $config = $self->plugin('Config', {file => $config_file});
  $self->secret(delete($config->{secret}));
  $self->log->level($config->{log_level});

  my $pit_config = pit_get('twitter_app_newsweb', require => {
    'consumer_key' => 'your consumer key for newsweb app',
    'consumer_secret' => 'your consumer secret for newsweb app',
    'access_token' => 'your access token for newsweb app',
    'access_token_secret' => 'your access token secret for newsweb app',
  });
  $config->{twitter_app} = $pit_config;

  # Redisのファクトリの作成
  $self->redis_factory(
    ChibaPM4::DB::RedisFactory->new(config => $config->{redis}));


  $self->stream(ChibaPM4::TwitterStream->new(app => $self));
  $self->stream->start;

  # ルーティング
  ChibaPM4::Web::Routes->setup($self->routes);
}

1;
__END__
vi:set sts=2 sw=2 et:
