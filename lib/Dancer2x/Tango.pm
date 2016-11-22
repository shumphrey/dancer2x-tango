# ABSTRACT: Dancer2 with separated routing and controllers.
package Dancer2x::Tango;

use strict;
use warnings;
use Import::Into;

sub import {
    my $class = shift;
    Dancer2->import::into(1, @_, dsl => 'Dancer2x::Tango::DSL');
}

1;

=head1 NAME

Dancer2x::Tango

=head1 SYNOPSIS

    use Dancer2x::Tango;
    get '/' => to('controller#action');

=head1 DESCRIPTION

Dancer2x::Tango is an experiment in separating routing and controller code in
Dancer2 applications. The following document assumes familiarity with L<Dancer2>.

Dancer2x::Tango is intended to replace C<use Dancer2;> and provides a C<to()>
keyword that handles dispatching this route to a method in the appropriate controller class.

Dancer2x::Tango imports L<Dancer2> into the caller so the caller gets all the L<Dancer2> DSL in addition
to the C<to()> keyword.

Dancer2x::Tango extends the L<Dancer2::Core::DSL> object, and as such it is currently not possible for the caller to also extend the DSL.

=head2 to("controller#action")

The C<to()> keyword handles dispatching to a controller class.

Given a Dancer2 app called My::App you might defined your routes in a package called C<My::App::Routes>

    package My::App::Routes;
    use Dancer2x::Tango;

    get '/' => to('root#index');
    get '/hello => to('root#hello');

Dancer2x::Tango would then dispatch these two routes to a controller class called C<My::App::Controller::Root> and call methods C<index> for / and C<hello> for /hello

If C<action> is ommitted, it is assumed to be index

=head2 Controller Classes

The controller class B<must> extend L<Dancer2x::Tango::Controller>

    package My::App::Controller::Root;
    use Moo;
    extends 'Dancer2x::Tango::Controller';

    sub index {
        my $self = shift;
        $self->dsl->template('root/index.tt');
    }

    sub hello {
        my $self = shift;
        $self->dsl->template('root/hello.tt');
    }

=head2 Middlewares

The C<to()> keyword can be given an additional hashref argument.

    to('controller#action', { with => [\&middlware], key => value });

The only argument that is understood at the moment is the middleware argument.
A middleware wraps the callback with additional callbacks.
Each callback is given as arguments, $next, $options, $controller

    sub middleware {
        my ($next, $options, $controller) = @_;

        // if some condition holds true
        return $next->();

        // otherwise return error
        return $controller->dsl->send_error('No such page', 404);
    }

=cut
