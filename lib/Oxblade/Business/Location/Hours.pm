package Oxblade::Business::Location::Hours;

use Moose;
use MooseX::Storage;

use Scalar::Util 'blessed';

use Data::Verifier;
use namespace::clean -except => 'meta';

use DateTime;
use DateTime::Set;
use DateTime::Event::ICal;

with Storage(             # Implementations for these are in this dist, at:
    'format' => 'Moose',  #  - MooseX::Storage::Format::Moose
    'io'     => 'Mongo'   #  - MooseX::Storage::IO::Mongo
);

# Should be an enum when we support this
has 'frequency' => (
    is      => 'ro',
    isa     => 'Str',
    default => 'weekly'
);

has 'days' => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
);

has 'start_time' => (
    is  => 'ro',
    isa => 'Int',
    required => 1,
);

has 'end_time' => (
    is  => 'ro',
    isa => 'Int',
    required => 1,
);

has '_ical' => (
    is      => 'ro',
    isa     => 'DateTime::Set',
    lazy    => 1,
    builder => '_build_ical',
    traits  => [ 'DoNotSerialize' ],
);

sub _build_ical {
    my ( $self ) = @_;

    my @formatted_days = ();

    push @formatted_days, 'mo' if $self->days->[0];
    push @formatted_days, 'tu' if $self->days->[1];
    push @formatted_days, 'we' if $self->days->[2];
    push @formatted_days, 'th' if $self->days->[3];
    push @formatted_days, 'fr' if $self->days->[4];
    push @formatted_days, 'sa' if $self->days->[5];
    push @formatted_days, 'su' if $self->days->[6];

    my $start = DateTime->now->truncate( to => 'day' );
    
    return DateTime::Event::ICal->recur(
        dtstart => $start,
        dtend   => $start->clone->add( days => 8 ),
        freq    => $self->frequency,
        byday   => \@formatted_days,
    );
}

sub is_open {
    my ( $self, $dt ) = @_;
    $dt ||= DateTime->now;
    my $day_check = $dt->clone->truncate( to => 'day' );

    if ( $self->_ical->contains( $day_check ) ) {
        my $int = int( sprintf("%02d%02d", $dt->hour, $dt->minute) );
        return 1 if $int > $self->start_time and $int < $self->end_time;
    }
    return 0;       
}

sub days_open {
    my ( $self ) = @_;

    my @dow  = ();

    while ( my $dt = $self->_ical->next ) {
        $dow[$dt->day_of_week - 1] = 1;
    }
    return \@dow;
}

no Moose;
__PACKAGE__->meta->make_immutable; 1;
