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
sub url { "http://api.bart.gov/api/" };
sub methods {
    departures  => [ 'etd.aspx' => {
        cmd   => 'etd',
        orig  => [ station    => $validate{station} ],
        plat  => [ platform   => qr/^[1-4]$/ ],
        dir   => [ direction  => qr/^[ns]$/ ],
    }],
    route       => [ 'route.aspx' => {
        cmd   => 'routeinfo',
        route => [ route_num  => [1..12], 'all' ],
        sched => [ sched_num  => qr/^\d+$/ ],
        date  => [ date       => $validate{date} ],
    }],
    routes      => [ 'route.aspx' => {
        cmd   => 'routes',
        sched => [ sched_num  => qr/^\d+$/ ],
        date  => [ date       => $validate{date} ],
    }],
    delays      => [ 'bsa.aspx' => {
        cmd   => 'bsa',
        orig  => [ station => $validate{station} ],
    }],
    trains      => [ 'bsa.aspx' => {
        cmd   => 'count',
    }],
    elevators   => [ 'bsa.aspx' => {
        cmd   => 'elev',
    }],
    station     => [ 'stn.aspx' => {
        cmd   => 'stninfo',
        orig  => [ station => $validate{station} ],
    }],
    stations    => [ 'stn.aspx' => {
        cmd   => 'stns',
        orig  => [ station => $validate{station} ],
    }],
    access      => [ 'stn.aspx' => {
        cmd   => 'stnaccess',
        orig  => [ station => $validate{station} ],
        l     => [ legend  => qr/^[01]$/ ],
    }],
};


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
    bless $class->SUPER::new(
        key  => $config{key},
    ), $class
}


1
