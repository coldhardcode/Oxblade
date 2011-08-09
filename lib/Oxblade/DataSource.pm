package Oxblade::DataSource;

use Moose::Role;

has '_provides' => (
    is       => 'ro',
    isa      => 'ArrayRef[Str]',
    traits   => [ 'Array' ],
    handles => {
        'provides' => 'elements',
    },
    builder => '_build_provides'
);

requires '_build_provides';
requires 'search';

no Moose::Role;
1;
