package Mojolicious::Plugin::LogMinimal;
use Mojo::Base 'Mojolicious::Plugin';

use MojoX::LogMinimal;

sub register {
  my $self = shift;
  my $app = shift;

  my $conf = shift || {};

  my $lm = MojoX::LogMinimal->new(logger => $app->log);
  $app->log($lm);

  if (exists($conf->{autodump})) {
    $Log::Minimal::AUTODUMP = $conf->{autodump};
  }
  if (exists($conf->{escape_whitespace})) {
    $Log::Minimal::ESCAPE_WHITESPACE = $conf->{escape_whitespace};
  }
}

1;
__END__
vi:set sts=2 sw=2 et:

