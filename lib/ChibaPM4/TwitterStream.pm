package ChibaPM4::TwitterStream;
use Mojo::Base -base;

use Log::Minimal;

use MojoX::Twitter::OAuth;
use MojoX::Twitter::Stream;

use ChibaPM4::Model::Tweets;

use Mojo::Util qw(dumper);

has 'app';

sub start {
  my $self = shift;

  my $config = $self->app->config->{twitter_app};

  my $oauth = MojoX::Twitter::OAuth->new(
    consumer_key    => $config->{consumer_key},
    consumer_secret => $config->{consumer_secret},
    token           => $config->{access_token},
    token_secret    => $config->{access_token_secret},
  );

  my $model = ChibaPM4::Model::Tweets->new(redis => $self->app->redis_factory->new_connection);

  my $stream = MojoX::Twitter::Stream->new(oauth => $oauth);

  $stream->on(
    'message' => sub {
      my ($stream, $data) = @_;

      if (!exists($data->{retweeted_status})) {
        my @data = (
          text => $data->{text},
          name => $data->{user}->{name},
          screen_name => $data->{user}->{screen_name},
          profile_image_url => $data->{user}->{profile_image_url},
        );
        $model->publish(@data);
      }
    }
  );
  $stream->on(
    'error' => sub {
      my ($stream, $err, $code) = @_;
      debugf $code ? "$code response: $err" : "Connection error: $err";
      debugf $stream->tx->res->body;
    }
  );
  $stream->on(
    'finish' => sub {
      my ($stream) = @_;
      debugf 'finish';
    }
  );
  $stream->request(
    GET => 'https://stream.twitter.com/1.1/statuses/filter.json' => form =>
      {track => '#chibapm'});
}

1;
__END__
vi:set sts=2 sw=2 et:
