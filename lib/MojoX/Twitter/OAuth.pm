package MojoX::Twitter::OAuth;
use Mojo::Base -base;

use OAuth::Lite::Util;

use Mojo::Loader;
use Mojo::Parameters;
use Mojo::Util qw(url_unescape);

has [qw(consumer_key consumer_secret token token_secret)];
has 'signature_method' => 'HMAC-SHA1';

sub _decompose_params {
  return map { url_unescape($_) }
         map { split(/=/, $_) } split(/&/, $_[0]);
}

sub get_oauth_parameters {
  my ($self, $req) = @_;

  my $url = $req->url->clone;
  my $params_str = $url->query->to_string;
  $url->query(Mojo::Parameters->new);

  my @params = &_decompose_params($params_str);
  my $content_type = $req->headers->content_type;
  if (defined($content_type) &&
      $content_type eq 'application/x-www-form-urlencoded') {
    push @params, &_decompose_params($req->body);
  }

  my $oauth_params = {
    @params,
    oauth_consumer_key => $self->consumer_key,
    oauth_nonce => OAuth::Lite::Util::gen_random_key(16),
    oauth_signature_method => $self->signature_method,
    oauth_token => $self->token,
    oauth_timestamp => time,
    oauth_version => '1.0',
  };

  return ($req->method, $url, $oauth_params);
}

sub create_signature_base_string {
  my ($self, $method, $url, $oauth_params) = @_;

  my $base_string = OAuth::Lite::Util::create_signature_base_string(
    $method, $url->to_string, $oauth_params);

  return $base_string;
}

sub signature_class {
  my $self = shift;

  my $class = $self->signature_method;
  $class =~ s/-/_/g;
  $class = join('::', 'OAuth::Lite::SignatureMethod', $class);
  if (my $e = Mojo::Loader->new->load($class)) {
    die ref $e ? "Excepion: $e" : "$class Not found";
  }
  return $class;
}

sub sign {
  my ($self, $base_string) = @_;

  my $signature_class = $self->signature_class;
  my $signer = $signature_class->new(
    consumer_secret => $self->consumer_secret,
    token_secret => $self->token_secret,
  );
  my $signature = $signer->sign($base_string);

  return $signature;
}

sub build_auth_header {
  my ($self, $params) = @_;

  my $auth = OAuth::Lite::Util::build_auth_header('', $params);
  $auth =~ s/^OAuth realm="",/OAuth/; # Twitterではrealm使わない

  return $auth;
}

sub header {
  my ($self, $req) = @_;

  my ($method, $url, $params) = $self->get_oauth_parameters($req);
  my $base_string = $self->create_signature_base_string($method, $url, $params);
  my $signature = $self->sign($base_string, $params);
  $params->{oauth_signature} = $signature;
  my $auth = $self->build_auth_header($params);

  return $auth;
}

1;
__END__
vi: set sts=2 sw=2 et:
