package Oxblade::DataManager;

use Moose;

extends 'Data::Manager';

use Scalar::Util 'blessed';
use Oxblade::Types qw(TimeZone);

has 'default_timezone' => (
    is      => 'ro',
    isa     => 'TimeZone',
    default => 'America/Los_Angeles'
);

sub values_for {
    my ( $self, $scope ) = @_;

    my $results = $self->get_results($scope);

    return undef if not defined $results;

    my %valids = $results->valid_values;

    my $tz = $valids{timezone} || $self->default_timezone;

    foreach my $valid ( keys %valids ) {
        if ( blessed($valids{$valid}) and $valids{$valid}->isa('DateTime') ) {
            $valids{$valid}->set_time_zone($tz);
        }
    }

    return \%valids;
}

no Moose;
__PACKAGE__->meta->make_immutable; 1;
