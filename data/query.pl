#!/bin/env perl

package Oxblade::Query::Geonames;

use Moose;

extends 'Oxblade::DataSource::Geonames';

with 'MooseX::Getopt';

sub run {
    my ( $self ) = @_;

    $self->search(@_);
}

no Moose;

package main;

use warnings;
use strict;

use Data::Dumper;

my $gn = Oxblade::Query::Geonames->new_with_options;

print Dumper( $gn->search( @{ $gn->extra_argv } ) );

