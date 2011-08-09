package Oxblade::Types;

use Moose::Util::TypeConstraints;

use MooseX::Types -declare => [qw(
    Email TimeZone EmailList StrList
    AppDateTime DateTimeWithinYear DateTimeWithinFutureYear
) ];

use MooseX::Types::Moose qw(Str Int ArrayRef HashRef);

use Email::Valid;

use DateTime;
use DateTimeX::Easy;
use DateTime::TimeZone;

subtype TimeZone,
    as Str,
    where {
        DateTime::TimeZone->is_valid_name( shift );
    };

subtype EmailList,
    as ArrayRef[Email];

subtype StrList,
    as ArrayRef[Str];

coerce EmailList,
    from Str,
    via { [
        grep { $_ }
        map { s/^\s+|\s+$//g }
        split(/\s*,\s*/, $_)
    ] };

coerce StrList,
    from Str,
    via {
        my $v = $_;
        [
            grep { $_ }
            map { s/^\s+|\s+$//g; $_; }
            split(/\s*,\s*/, $v)
        ]
    };


# Dates
class_type AppDateTime, { class => 'DateTime' };

coerce AppDateTime,
    from Str,
    via {
        my $dt = DateTimeX::Easy->parse($_);
        return undef unless $dt;
        if ( $dt->year < 1930 ) { $dt->set_year( $dt->year + 100 ) };
        return $dt;
    };

coerce AppDateTime,
    from HashRef,
    via {
        my $dt = DateTimeX::Easy->parse(join(" ", $_->{date}, $_->{time}));
        return undef unless $dt;
        if ( $dt->year < 1930 ) { $dt->set_year( $dt->year + 100 ) };
        return $dt;
    };

subtype DateTimeWithinYear,
    as AppDateTime,
    where {
        my $val   = shift;
        my $dt    = DateTime->now;
        my $delta = $dt - $val;
        return ( $delta->years < 1 );
    };

subtype DateTimeWithinFutureYear,
    as AppDateTime,
    where {
        my $val   = shift;
        my $dt    = DateTime->now->add( years => 1 );
        return ( $dt >= $val );
    };

1;
