use strict;
use warnings;

use Test::More;
use Data::Dumper;

use WebService::BART;

my $bart = WebService::BART->new;
my $departures = $bart->departures;
ok $departures;
print Dumper $departures;

done_testing 1
