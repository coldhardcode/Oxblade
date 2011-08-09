use Test::More;

use FindBin;

use_ok('Oxblade::Business');
use_ok('Oxblade::DataSource::Geonames');

my $names = Oxblade::DataSource::Geonames->new(
    dbfile => "$FindBin::Bin/../data/geonames.db"
);

my $biz = Oxblade::Business->new(
    name        => q{Bob's Widget Hut},
    datasources => { map { $_ => $names } $names->provides },
);

my $location = $biz->add_location({
    address => {
        street  => '1234 Test St',
        city    => 'San Francisco',
        state   => 'CA',
        country => 'US',
        postal  => '94107'
    }
});

is($location->timezone, 'America/Los_Angeles', 'correct tiemzone');

done_testing;

