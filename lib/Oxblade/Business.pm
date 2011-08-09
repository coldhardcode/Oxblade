package Oxblade::Business;

use Carp 'croak';
use Moose;
use MooseX::Storage;

use Scalar::Util 'blessed';
use Data::Verifier;
use namespace::clean -except => 'meta';

use Oxblade::Business::Location;
use Oxblade::Locale;

with Storage(             # Implementations for these are in this dist, at:
    'format' => 'Moose',  #  - MooseX::Storage::Format::Moose
    'io'     => 'Mongo'   #  - MooseX::Storage::IO::Mongo
);

has 'datasources' => (
    is          => 'ro',
    isa         => 'HashRef[Oxblade::DataSource]',
    required    => 1,
    traits      => [ 'DoNotSerialize', 'Hash' ],
    handles     => {
        'datasource_for' => 'get'
    }
);

has 'locations' => (
    is => 'ro',
    isa => 'ArrayRef[Oxblade::Business::Location]',
    default => sub { [] }
);

sub add_location {
    my ( $self, $loc_or_ref ) = @_;

    # I really hate everything that this method does.

    my $location;
    if ( blessed($loc_or_ref) and $loc_or_ref->isa('Oxblade::Business::Location') ) {
        $location = $loc_or_ref;
    } else {
        my $args = $loc_or_ref;
        croak "must provide at least city and state" 
            unless $args->{city} and $args->{state};

        if ( not $args->{timezone} ) {
            # Find out what service fetches timezones.
            my $results = $self->datasource_for('timezone')->search(
                join(", ", $args->{address}->{city}, $args->{address}->{state})
            );

            foreach my $item ( @{ $results->items } ) {
                if ( $item->get_value('timezone') ) {
                    $args->{timezone} = $item->get_value('timezone');
                    last;
                }
            }
            unless ( $args->{timezone} ) {
                croak "Must specify timezone, could not find it from the address";
            }
        }
        $location = Oxblade::Business::Location->new( $args );
    }

    croak "Invalid call to add_location, must give proper parameters or a location object" unless $location;

    $self->_add_location($loc_or_ref);
}

sub open_locations {
    my $self = shift;

    return grep { $self->is_open( @_ ) } $self->all_locations;
}

no Moose;
__PACKAGE__->meta->make_immutable; 1;
