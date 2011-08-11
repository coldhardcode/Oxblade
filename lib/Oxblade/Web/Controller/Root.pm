package Oxblade::Web::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Oxblade::Web::Controller::Root - Root Controller for Oxblade::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # Hello World
    $c->response->body( $c->welcome_message );
}

sub guide : Path('guide') Args() {
    my ( $self, $c, $layout ) = @_;

    $c->stash->{in_the_guide} = 1;

    if ( defined $layout and -f $c->path_to("root/guide", "$layout.tt") ) {
        $c->stash->{template} = "guide/$layout.tt";
    } else {
        $layout = undef;
    }

    if ( $c->req->method eq 'POST' and $layout ) {
        my $dm = $c->model('DataManager');
        if ( defined $dm->get_verifier($layout) ) {
            my $results = $dm->verify($layout, $c->req->params);
            if ( $results->success ) {
                $c->message($c->loc('Valid data was passed in. Yahoo!'));
            } else {
                $c->message({
                    type => 'error',
                    message => $c->loc('This is an error message.')
                });
            }
        }
        $c->res->redirect( $c->uri_for_action('/guide', $layout) );
    }
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Jay Shirley

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
