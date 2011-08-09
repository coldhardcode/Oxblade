package Oxblade::Locale;

use Moose::Role;
use Oxblade::DataManager;

has 'data_manager' => (
    is  => 'ro',
    isa => 'Oxblade::DataManager',
    lazy => 1,
    default => sub { Oxblade::DataManager->new }
);

has 'verifier' => (
    is  => 'ro',
    isa => 'Oxblade::DataManager',
    lazy => 1,
    builder => '_build_verifier',
);

sub _build_verifier {
    my ( $self ) = @_;

    my $dm = $self->data_manager;

    $dm->set_verifier('phone', $self->phone_verifier );
    $dm->set_verifier('address', $self->address_verifier );

    return $dm;
}

sub verify_address { shift->verify('address', @_); }
sub verify_phone { shift->verify('phone', @_); }

requires 'phone_verifier';
requires 'address_verifier';

no Moose::Role;
1;
