package Dancer2x::Tango::Controller;

use Moo;
use Types::Standard qw/InstanceOf/;

## This gets given to the controller on instantiation
has dsl => (
    is       => 'rw',
    isa      => InstanceOf['Dancer2x::Tango::DSL'],
    required => 1,
    weak_ref => 1, # Should only exist for the lifetime of the Dancerx::Controller closures
    handles  => [qw/session template request response redirect vars
                    body_parameters query_parameters route_parameters captures splat
                    send_error forward pass/],
);

=head1 NAME

Dancer2x::Tango::Controller

=head1 DESCRIPTION

Base class for Dancer2x::Tango controllers.

Typically Your application will create an app specific base controller class that extends this one.

    package My::App::Controller;
    use Moo;
    extends 'Dancer2x::Tango::Controller';

    sub something {
        // Common method for all controllers
    }

and then

    package My::App::Controller::Root;
    use Moo;
    extends 'My::App::Controller';

    sub index {
        my $self = shift;
        my $something = $self->something();
        my $self->dsl->template('root/index.tt');
    }

=cut

1;
