package Oxblade::Business::Location::Hours;

use Moose;
use MooseX::Storage;

use Scalar::Util 'blessed';
use Data::Verifier;
use namespace::clean -except => 'meta';

with Storage(             # Implementations for these are in this dist, at:
    'format' => 'Moose',  #  - MooseX::Storage::Format::Moose
    'io'     => 'Mongo'   #  - MooseX::Storage::IO::Mongo
);

has 'days' => (
    is  => 'ro',
    isa => 'ArrayRef[Int]'
);

sub open_monday    { return defined $self->days->[1]; }
sub open_tuesday   { return defined $self->days->[2]; }
sub open_wednesday { return defined $self->days->[3]; }
sub open_thursday  { return defined $self->days->[4]; }
sub open_friday    { return defined $self->days->[5]; }
sub open_saturday  { return defined $self->days->[6]; }
sub open_sunday    { return defined $self->days->[0]; }

no Moose;
__PACKAGE__->meta->make_immutable; 1;
