use Test::More;
use DateTime;

use_ok('Oxblade::Business');

my $biz = Oxblade::Business->new(
    name => q{Bob's Widget Hut}
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

is_deeply(
    $location->hours_by_day,
    [ [], [], [], [], [], [], [] ],
    'no hours'
);

is( $location->is_open, 0, 'not open now' );

$location->hours_for(
    'Monday', # Or 1, or 'M', or 'Mon', etc
    [
        8,  12, # Open from 10 to noon.
        13, 17, # Then from 1 to 5pm.
    ]
);

is_deeply(
    $location->hours_by_day,
    [ [], [ 800, 1200, 1300, 1700 ], [], [], [], [], [] ],
    'monday hours'
);

$location->hours_for(
    'Weekday',  # Initialization, won't overwrite previous values.
    [ 18, 20 ], # Every weekday, open from 6pm to 8pm
);

is_deeply(
    $location->hours_by_day,
    [ [], [ 800, 1200, 1300, 1700 ], [ 1800, 2000 ], [ 1800, 2000 ], [ 1800, 2000 ], [ 18, 20 ], [] ],
    'monday hours kept, weekday hours are set'
);

is_deeply(
    $locations->days_open_at(1800);
    # Open  T  W  Th F
    [ 0, 0, 1, 1, 1, 1, 0 ],
    'open on the set days'
);

my $monday = DateTime->now;
    my $days_till_monday = 7 - $monday->day_of_week;
    $monday->add( days => $days_till_monday );
    $monday->set( hour => 13, minute => 00 );

is( $location->is_open( $monday ), 1, 'open on next monday' );

# Next Monday and only next monday do we have different hours.
$location->hours_exception(
    $monday => [ 1700, 2400 ]
);

is( $location->is_open( $monday ), 0, 'not open on next monday after exception' );

my $holiday = $now->clone->add( days => 5 );
is( $location->is_open( $holiday ), 1, 'open on holiday before set' );

$locations->add_hours_exception( $holiday );
is( $location->is_open( $holiday ), 0, 'not open on holiday' );

my $biz_holiday = $holiday->clone->add( days => 5 );
$business->add_hours_exception( $biz_holiday );
is( $location->is_open( $biz_holiday ), 0, 'not open on biz_holiday' );

