package Mojolicious::Plugin::LogWarn;
use Mojo::Base 'Mojolicious::Plugin';

use MojoX::LogWarn;

sub register {
  my $self = shift;
  my $app = shift;

  my $conf = shift || {};

  MojoX::LogWarn->setup($app->log);
}

1;
__END__
vi:set sts=2 sw=2 et:
