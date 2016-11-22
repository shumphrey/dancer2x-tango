package Dancer2x::Tango::Dispatcher;

use strict;
use warnings;
use Class::Load qw/load_class/;
use Safe::Isa;
use Carp;

use parent 'Exporter';

our @EXPORT_OK = qw/to/;

## Cache the controllers instances
my $_CONTROLLER_CACHE = {};

sub import {
    my ($class) = @_;
    $class->export_to_level(1, @_);
}


sub to {
    my ( $dsl, $controller_name, $options ) = @_;
    $options ||= {};
    my ($controller_class, $action) = _load($dsl, $controller_name);

    ## Our to() function can be called with a bunch of middleware wrappers
    ## the 'with' keyword is a reserved arrayref containing each middleware
    my $wrappers = delete $options->{with};

    ## We first return a callback function to Dancer2's route handler
    ## This callback calls a method on our controller class
    my $sub = sub {
        return shift->$action(@_);
    };

    ## This complicated section wraps each sub with a middleware sub
    ## Each middleware is called with ($next, $options, $controller, $d2app)
    ## Each middleware either calls the next middleware or exits the chain.
    ##
    ## This is used for things like ensuring the user has sufficient permissions
    for my $wrap (@{$wrappers || []}) {
        my $orig = $sub;
        $sub = sub {
            my ($c) = @_;
            return $wrap->(sub {
                $orig->($c);
            }, $options, $c);
        };
    }

    ## The outer callback ensures our controller has access to the app
    ## This is so that helper methods on the base controller have access to the
    ## request and session.
    return sub {
        my $app = shift;
        $sub->($controller_class);
    }
}

sub _load {
    my $dsl = shift;
    my ($name, $action) = split(/#/, shift);
    $action ||= 'index';
    my $class_name = _camelise($name);
    if ( !$_CONTROLLER_CACHE->{$class_name} ) {
        my $namespace = caller(3);
        $namespace =~ s/::Routes?.*//;
        $namespace .= '::Controller::';

        my $class = load_class $namespace . $class_name;
        $_CONTROLLER_CACHE->{$class_name} = $class->new(dsl => $dsl);
        if ( !$_CONTROLLER_CACHE->{$class_name}->$_isa('Dancer2x::Tango::Controller') ) {
            croak 'Controller class does not extend from Dancer2x::Tango::Controller';
        }
    }
    return ($_CONTROLLER_CACHE->{$class_name}, $action);
}

sub _camelise {
    my $name = ucfirst shift;
    $name =~ s/_(\p{IsLower})/uc($1)/eg;
    return $name;
}

=head1 NAME

Dancer2x::Tango::Dispatcher

=head1 DESCRIPTION

Methods for loading and dispatching to Dancer2x::Tango controllers.

=head1 METHODS

=over 4

=item to($controller, $options)

Returns a callback for a Dancer2 route.
Handles dispatching to the appropiate subroutine in a Dancer2x::Tango controller.

$controller is a string like C<"root#login">.
This will find a controller called <NAMESPACE>::Controller::Root and dispatch
to a method called login.

For example, if your routes are defined in a module called C<Web::Routes::Base>
to("root#login") will dispatch to Web::Controller::Root->new->login

All controllers are cached.

The C<to()> keyword can be given an additional hashref argument.

    to('controller#action', { with => [\&middlware], key => value });

The only argument that is understood at the moment is the middleware argument C<with>.
A middleware wraps the callback with additional callbacks.
Each callback is given as arguments, C<$next>, C<$options = {}>, C<$controller>

    sub middleware {
        my ($next, $options, $controller) = @_;

        // if some condition holds true
        return $next->();

        // otherwise return error
        $controller->dsl->send_error('No such page', 404);
    }

C<with> takes an arrayref of middleware callback functions to apply before the controller action.

=back

=cut

1;
