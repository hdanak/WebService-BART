package WebService::BART::API;
use parent qw| WebService::Wrapper |;

our $VERSION = '0.01';

use Modern::Perl;

=head1 NAME

WebService::BART::API

=head1 SYNOPSIS

  use WebService::BART::API;
  my $bart_api = WebService::BART::API->new(key => 'MW9S-E7SL-26DU-VV8V');
  $bart_api->routes     # get /route.aspx?cmd=routes

=cut

my %validate = (
    station => sub { $_[0] ~~ /[a-z0-9]{4}/i },
    date    => sub { $_[0] ~~ m(^\d\d/\d\d/\d{4}|today|now$)i },
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
        route => [ route      => [1..12], 'all' ],
        sched => [ schedule   => qr/^\d+$/ ],
        date  => [ date       => $validate{date} ],
    }],
    routes      => [ 'route.aspx' => {
        cmd   => 'routes',
        sched => [ schedule   => qr/^\d+$/ ],
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
    arrivals    => [ 'stn.aspx' => {
        cmd   => 'stns',
        orig  => [ station => $validate{station} ],
    }],
    access      => [ 'stn.aspx' => {
        cmd   => 'stnaccess',
        orig  => [ station => $validate{station} ],
        l     => [ legend  => qr/^[01]$/ ],
    }],
};

