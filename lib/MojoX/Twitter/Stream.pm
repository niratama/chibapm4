package MojoX::Twitter::Stream;
use Mojo::Base 'Mojo::EventEmitter';

use Log::Minimal;

use Mojo::UserAgent;
use Mojo::JSON;

has 'oauth';
has 'timeout' => 300;
has 'json' => sub { Mojo::JSON->new };
has 'ua' => sub { Mojo::UserAgent->new };
has 'tx';

sub _send_message {
  my $self = shift;
  my $bytes = shift;

  debugf 'bytes: %s', $bytes;
  $bytes =~ s/[\r\n]*$//g;
  return if $bytes eq '';

  if (defined(my $data = $self->json->decode($bytes))) {
    $self->emit('message', $data);
  } else {
    $self->emit('error', $self->json->error, undef, $bytes);
  }
}

sub _check_progress {
  my ($self, $res, $state, $offset) = @_;

  return if $self->{code_checked};
  return unless defined($res->code);

  $self->{code_checked} = 1;

  if ($res->is_status_class(200)) {
    $res->content->unsubscribe('read')->on('read' => sub {
        $self->_send_message($_[1]);
      });
  }
}

sub _finish {
  my ($self, $ua, $tx) = @_;

  if (my $res = $tx->success) {
    $self->emit('finish');
  } else {
    my ($err, $code) = $tx->error;
    $self->emit('error', $err, $code);
  }
  $self->tx(undef);
}

sub request {
  my ($self, @txargs) = @_;

  $self->{code_checked} = 0;
  $self->ua->inactivity_timeout($self->timeout);
  $self->ua->on('start' => sub {
      my ($ua, $tx) = @_;
      $self->tx($tx);
      $tx->req->headers->authorization($self->oauth->header($tx->req));
      $tx->res->on('progress' => sub { $self->_check_progress(@_) });
    });
  $self->ua->start($self->ua->build_tx(@txargs), sub { $self->_finish(@_) });
}

sub close {
  my $self = shift;

  return unless $self->tx;
  $self->tx->client_close;
}

1;
__END__
vi: set sts=2 sw=2 et:

