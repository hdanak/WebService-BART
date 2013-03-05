package WebService::BART;
use parent qw| WebService::Wrapper |;
our $VERSION = '0.01';

use Modern::Perl;

=head1 NAME

WebService::BART

=head1 SYNOPSIS

  use WebService::BART;
  my $bart = WebService::BART->new(key => 'MW9S-E7SL-26DU-VV8V');

=cut


my %validate = (
    station => sub { lc =~ /[a-z0-9]{4}/ ? lc : 'all' },
    date    => sub { lc =~ m(^ \d\d/\d\d/\d{4}|today|now $)x ? lc : () }
);
our $BASE_URL = "http://api.bart.gov/api/";
our $METHODS  = {
    advisory    => [ '/bsa.aspx'    => {
        delays      => [{ cmd   => 'bsa',
                          orig  => [ station => $validate{station} ],
                        }],
        trains      => [{ cmd   => 'count' }],
        elevators   => [{ cmd   => 'elev' }],
    }],
    estimate    => [ '/etd.aspx'    => {
        departures  => [{ cmd   => 'etd',
                          orig  => [ station    => $validate{station} ],
                          plat  => [ platform   => qr/^[1-4]$/ ],
                          dir   => [ direction  => qr/^[ns]$/ ],
                        }],
    }],
    route       => [ '/route.aspx'  => {
        info        => [{ cmd   => 'routeinfo',
                          route => [ route_num  => [1..12], 'all' ],
                          sched => [ sched_num  => qr/^\d+$/ ],
                          date  => [ date       => $validate{date} ],
                        }],
        list        => [{ cmd   => 'routes',
                          sched => [ sched_num  => qr/^\d+$/ ],
                          date  => [ date       => $validate{date} ],
                        }],
    }],
    schedule    => [ '/sched.aspx'  => {
        arrival     => [{ cmd   => 'arrive' }],
        departure   => [{ cmd   => 'depart' }],
        fare        => [{ cmd   => 'fare' }],
        holiday     => [{ cmd   => 'holiday' }],
        list        => [{ cmd   => 'scheds' }],
        special     => [{ cmd   => 'special' }],
        route       => [{ cmd   => 'routesched' }],
        station     => [{ cmd   => 'stnsched' }],
    }],
    station     => [ '/stn.aspx'    => {
        info        => [{ cmd   => 'stninfo',
                          orig  => [ station => $validate{station} ],
                        }],
        access      => [{ cmd   => 'stnaccess',
                          orig  => [ station => $validate{station} ],
                          l     => [ legend  => qr/^[01]$/ ],
                        }],
        list        => [{ cmd   => 'stns' }],
    }],
};


=head1 METHODS

=head2 WebService::BART->new(
    key => I<$API_key>
)

=cut

sub new {
    my ($class, %config) = @_;
    unless ($config{key} =~ /^[A-Z0-9-]+$/) {
        $config{key} = 'MW9S-E7SL-26DU-VV8V'
    }
    $class->SUPER::new(
        key  => $config{key},
    )
}


1
__END__

=head1 AUTHOR

Hike Danakian

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Hike Danakian

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14.2 or,
at your option, any later version of Perl 5 you may have available.


=cut
