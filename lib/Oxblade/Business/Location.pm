package Oxblade::Business::Location;

use Moose;
use MooseX::Storage;

use Scalar::Util 'blessed';
use Data::Verifier;
use namespace::clean -except => 'meta';

use Oxblade::Locale;

with Storage(             # Implementations for these are in this dist, at:
    'format' => 'Moose',  #  - MooseX::Storage::Format::Moose
    'io'     => 'Mongo'   #  - MooseX::Storage::IO::Mongo
);

has 'locale' => (
    is          => 'ro',
    isa         => 'Str',
    required    => 1,
    handles     => {
        'verify_address' => 'verify_address',
        'verify_phone'   => 'verify_phone',
    }
);

has 'address' => (
    is          => 'ro',
    isa         => 'HashRef',
    required    => 1,
);

has 'timezone' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'hours' => (
    is   => 'ro',
    isa  => 'ArrayRef[Oxblade::Business::Location::Hours]',
    default => sub { [] },
    traits  => [ 'Array' ],
    handles => {
        'add_hours_exception' => 'add_hours_exception',
    }
);

=method is_open(?$dt?)

Is this location open on the specified date? If not specified, defaults to now.

=cut

sub is_open {
    my ( $self, $dt ) = @_;
    $dt ||= DateTime->now( timezone  => $self->timezone );

    foreach my $hour ( $self->all_hours ) {
        return 1 if $hour->is_open;
    }

    return 0;
}

no Moose;
__PACKAGE__->meta->make_immutable; 1;
