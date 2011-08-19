package Oxblade::DataSource::Geonames;

use Moose;

use Data::SearchEngine::Query;
use Data::SearchEngine::Results;
use Data::SearchEngine::Paginator;
use Data::SearchEngine::Item;

use Geo::GeoNames::DB::SQLite;

with 'Oxblade::DataSource';

has 'dbfile' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'geonames_db' => (
    is   => 'ro',
    isa  => 'Geo::GeoNames::DB::SQLite',
    lazy => 1,
    default => sub {
        my ( $self ) = @_;
        Geo::GeoNames::DB::SQLite->connect( $self->dbfile );
    },
);

sub search {
    my $self = shift;

    my $query = Data::SearchEngine::Query->new(
        query => join(" ", @_)
    );

    my $results = Data::SearchEngine::Results->new(
        query => $query,
        pager => Data::SearchEngine::Paginator->new(
            entries_per_page => 10,
            total_entries    => 10,
        )
    );

    #warn "Searching for " . $query->query;
    my @r = $self->geonames_db->query( $query->query );

#use Data::Dumper;
#warn Dumper(\@r);
    my @items;
    foreach my $row ( @r ) {
        my $score = 0;
        if ( $row->{population} ) {
            $score += 1;
        }
        if ( $row->{alternatenames} ) {
            $score += 0.25;
        }
        if ( my $c = $row->{feature_code} ) {
            $score += 0.75 if $c eq 'PPLA';
            $score += 0.50 if $c eq 'PPLA2';
            $score += 0.35 if $c eq 'PPLA3';
            $score += 0.20 if $c eq 'PPLA4';
        }
        my $item = Data::SearchEngine::Item->new(
            id    => $row->{geonameid},
            score => $score,
        );
        foreach my $key ( keys %$row ) {
            $item->set_value($key, $row->{$key});
        }

        push @items, $item;
    }
    $results->add( sort { $b->score <=> $a->score } @items );
    return $results;
}

sub _build_provides {
    return [ 'timezone', 'address' ];
}

sub DEMOLISH {
    my ( $self ) = @_;
    $self->geonames_db->disconnect;
}

no Moose;
__PACKAGE__->meta->make_immutable;
