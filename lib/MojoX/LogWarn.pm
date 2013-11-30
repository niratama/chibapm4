package MojoX::LogWarn;
use Mojo::Base -strict;

sub setup {
  my ($this, $log) = @_;

  $SIG{'__WARN__'} = sub {
    my $msg = shift;
    chomp($msg);
    unshift @_, $log, $msg;
    goto $log->can('warn');
  };
}

1;
__END__
vi:set sts=2 sw=2 et:
