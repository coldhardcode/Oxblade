package Oxblade::Locale::US;

use Moose;
use Data::Verifier;

with 'Oxblade::Locale';

sub phone_verifier {
    my ( $self ) = @_;

    Data::Verifier->new(
        filters => [ 'trim' ]
        profile => {
            'phone' => {
                type => 'Str',
                required => 1,
                post_check => sub {
                    my $r = shift;
                    my $phone = $r->get_value('phone');
                    return ( $phone =~ /(\d{3}).?(\d{3}).?(\d{4})/ );
                },
            },
            'extension' => {
                type => 'Str',
                post_check => sub {
                },
            }
        }
    );

}

sub address_verifier {
    my ( $self ) = @_;

    Data::Verifier->new(
        filters => [ 'trim' ]
        profile => {
            street => {
                type     => 'Str',
                required => 1,
            },
            street2 => {
                type => 'Str'
            },
            city => {
                type     => 'Str',
                required => 1,
            },
            state => {
                type     => 'Str',
                required => 1,
                filter   => [ 'uc' ],
                post_check => sub {
                    my $r = shift;
                    my $state = $r->get_value('state');
                    return $state =~ /^[A-Z]{2}$/;
                }
            },
            country => {
                type     => 'Str',
                required => 1,
                post_check => sub {
                    my $r = shift;
                    my $country = $r->get_value('country');
                    return $country =~ /^[A-Z]{2}$/;
                }
            },
            postal => {
                type => 'Str',
                required => 1,
                post_check => sub {
                    my $r = shift;
                    my $postal = $r->get_value('postal');
                    return $postal =~ /^\d{5}(?:-?\d{4})$/;
                }
            }
        }
    );
}

no Moose;
__PACKAGE__->meta->make_immutable; 1;
