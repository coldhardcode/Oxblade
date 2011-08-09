#!/bin/env perl

package BizWidgets::Importer::Geonames;

use Moose;

use Geo::GeoNames::File;
use Geo::GeoNames::DB::SQLite;

with 'MooseX::Getopt';

has 'files' => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    required => 1,
    traits   => [ 'Array' ],
    handles  => {
        'all_files' => 'elements'
    }
);

has 'dbfile' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1,
);

has 'geonames_file' => (
    is   => 'ro',
    isa  => 'Geo::GeoNames::File',
    lazy => 1,
    default => sub {
        my ( $self ) = @_;
        Geo::GeoNames::File->open( $self->all_files );
    }
);

has 'geonames_db' => (
    is   => 'ro',
    isa  => 'Geo::GeoNames::DB::SQLite',
    lazy => 1,
    default => sub {
        my ( $self ) = @_;
        Geo::GeoNames::DB::SQLite->connect( $self->dbfile );
    }
);

sub run {
    my ( $self ) = @_;

    $self->geonames_db->insert( $self->geonames_file );
    $self->geonames_file->close;
    $self->geonames_db->commit;
    $self->geonames_db->disconnect;
}

no Moose;

package main;

use warnings;
use strict;


my $importer = BizWidgets::Importer::Geonames->new_with_options;
my $method   = 'run';

$importer->$method;
