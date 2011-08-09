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
    isa  => 'Oxblade::Business::Location::Hours',
    lazy => 1,
    default => sub { Oxblade::Business::Location::Hours->new },
    handles => {
        'add_hours_exception' => 'add_hours_exception',
        'is_open'       => 'is_open',
        'hours_by_day'  => 'hours_by_day',
        'hours_for'     => 'hours_for',
    }
);

no Moose;
__PACKAGE__->meta->make_immutable; 1;
