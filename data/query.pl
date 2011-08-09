#!/bin/env perl

package BizWidgets::Query::Geonames;

use Moose;

extends 'BizWidgets::DataSource::Geonames';

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

my $gn = BizWidgets::Query::Geonames->new_with_options;

print Dumper( $gn->search( @{ $gn->extra_argv } ) );

