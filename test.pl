use WebService::BART;
use Data::Dumper;
my $bart = WebService::BART->new;
print Dumper $bart->departures(station => 'embr')
