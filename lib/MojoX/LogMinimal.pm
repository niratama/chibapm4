package MojoX::LogMinimal;
use Mojo::Base -base;

use Log::Minimal;

has 'logger';

has 'lm_debug' => 1;

our $TYPE_MAP = {
  'critical' => 'fatal',
};
our $TYPE_RMAP = { reverse %$TYPE_MAP };

sub new {
  my $self = shift->SUPER::new(@_);
  $Log::Minimal::PRINT = sub {
    my ($time, $type, $message, $trace, $raw_message) = @_;
    if (ref($self->logger) && $self->logger->can('log')) {
      $type = $TYPE_MAP->{lc($type)} // lc($type);
      $self->logger->log($type, "$message at $trace");
    } else {
      warn "$time [$type] $message at $trace\n";
    }
  };
  $self->level($self->logger->level) if $self->logger;
  return $self;
}

sub level {
  my $self = shift;
  if (@_ == 0) {
    return $self->logger->level;
  }
  my $level = shift;
  $self->logger->level($level);
  $Log::Minimal::LOG_LEVEL = uc($TYPE_RMAP->{$level} // $level);
  if ($self->lm_debug) {
    $ENV{'LM_DEBUG'} = ($level eq 'debug') ? 1 : 0;
  }
}

sub DESTROY {}

sub AUTOLOAD {
  my $method = our $AUTOLOAD;
  $method =~ s/.*:://o;
  no strict 'refs';
  *{$AUTOLOAD} = sub { shift->logger->$method(@_) };
  goto &$AUTOLOAD;
}

1;
__END__
vi:set sts=2 sw=2 et:
