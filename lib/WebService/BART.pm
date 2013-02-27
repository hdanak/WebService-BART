
package WebService::BART;
our $VERSION = '0.01';

=head1 NAME

WebService::BART

=head1 SYNOPSIS

  use WebService::BART;
  my $bart = WebService::BART->new(key => 'MW9S-E7SL-26DU-VV8V');

=cut

use Modern::Perl;

use parent qw( WebService::Wrapper );

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

=head2 BART::API->new(
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

1;

package WebService::BART::Exporter::Plugins::Pretty;
our $VERSION = '0.01';

use Modern::Perl;

sub name { "pretty" }
sub convert {
    join '', map {
        sprintf "%s (%s cars) - %s minutes\n",
                $$_{destination}, $$_{estimate}[0]{length},
                join ', ', map {$$_{minutes}} @{$$_{estimate}}
    } @{$$feed{station}{etd}}
}

1;
