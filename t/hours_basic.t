use Test::More;
use DateTime;

use_ok('Oxblade::Business::Location::Hours');

my %days = (
    1 => 'Monday',
    2 => 'Tuesday',
    3 => 'Wednesday',
    4 => 'Thursday',
    5 => 'Friday',
    6 => 'Saturday',
    7 => 'Sunday',
);

{
    my $hours = Oxblade::Business::Location::Hours->new(
        timezone   => 'America/Los_Angeles',
        days       => [ qw/1 1 1 1 1 1 1/ ],
        start_time => '1030',
        end_time   => '2200'
    );

    my $dt  = DateTime->now;
        $dt->set( hour => 11, minute => 00 );
        # Get us to next Monday
        $dt->add( days => ( 7 - $dt->day_of_week + 1 ) );

    my $dow = $dt->day_of_week;
#diag($dow);

    for my $day ( 0 .. 6 ) {
        #diag("( $dow + $day ) % 7 = " . ( ( $dow + $day ) % 7 ) );
        my $cur_dt  = $dt->clone->add( days => $day );
        my $cur_dow = $cur_dt->day_of_week;

        ok($hours->is_open($cur_dt), "open on $days{$cur_dow}");
    }

    ok(!$hours->is_open($dt->clone->set( hour => 9 )), 'not open before 10:30');
    ok(!$hours->is_open($dt->clone->set( hour => 22, minute => 1 )), 'not open after 22:00');
 
    is_deeply(
        $hours->days_open,
        [ qw/1 1 1 1 1 1 1/ ],
        'correct days open'
    );
}

{
    my $hours = Oxblade::Business::Location::Hours->new(
        timezone   => 'America/Los_Angeles',
        days       => [ qw/0 1 1 1 1 1 0/ ],
        start_time => '1030',
        end_time   => '2200'
    );

    my $dt  = DateTime->now;
        $dt->set( hour => 11, minute => 00 );
        # Get us to next Monday
        $dt->add( days => ( 7 - $dt->day_of_week + 1 ) );

    my $dow = $dt->day_of_week;
#diag($dow);

    for my $day ( 0 .. 6 ) {
        #diag("( $dow + $day ) % 7 = " . ( ( $dow + $day ) % 7 ) );
        my $cur_dt  = $dt->clone->add( days => $day );
        my $cur_dow = $cur_dt->day_of_week;

        if ( $day == 0 or $day == 6 ) {
            ok(!$hours->is_open($cur_dt), "closed on $days{$cur_dow}");
        } else {
            ok($hours->is_open($cur_dt), "open on $days{$cur_dow}");
        }
    }
 
    is_deeply(
        $hours->days_open,
        [ qw/0 1 1 1 1 1 0/ ],
        'correct days open'
    );
}

done_testing;
