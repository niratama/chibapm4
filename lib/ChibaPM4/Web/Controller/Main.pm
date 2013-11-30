package ChibaPM4::Web::Controller::Main;
use Mojo::Base 'Mojolicious::Controller';

sub root {
  my $self = shift;

  $self->redirect_to('index.html');
}

1;
__END__
vi:set sts=2 sw=2 et:
