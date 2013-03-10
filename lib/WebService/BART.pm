package WebService::BART;

our $VERSION = '0.01';

=head1 NAME

WebService::BART

=head1 SYNOPSIS

  use WebService::BART;
  my $bart = WebService::BART->new(key => 'MW9S-E7SL-26DU-VV8V');

=cut

use Modern::Perl;
use WebService::BART::API;
use AnyEvent;
use AnyEvent::Strict;

=head1 METHODS

=head2 WebService::BART->new(
    key => I<$API_key>
)

=cut

sub new {
    my ($class, %config) = @_;
    unless (exists $config{key} and $config{key} =~ /^[A-Z0-9-]+$/) {
        $config{key} = 'MW9S-E7SL-26DU-VV8V'
    }
    my $self = bless {
        api => WebService::BART::API->new(key => $config{key}),
    }, $class;
}
sub api { shift->{api} }

sub notify_arrivals {
}
sub notify_departures {
}
sub notify_delays {
}
sub notify {
    my ($self, $method, $args, $action, $interval) = @_;
    $action   //= sub {};
    $interval //= 30;

    return AnyEvent->timer(
        after       => $interval,
        interval    => $interval,
        cb          => sub {
            $action->($self->api->_method($method)->(%$args))
        },
    )
}


1
