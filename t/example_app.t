#!/usr/bin/env perl

## no critic (Modules::ProhibitMultiplePackages)

use strict;
use warnings;

# A base controller class
{
    package My::App::Controller;
    use Moo;
    extends 'Dancer2x::Tango::Controller';

    sub user {
        my $self = shift;

        if ( !$self->dsl->vars->{user} ) {
            $self->dsl->vars->{user} = 'Bob Cat';
        }
        return $self->dsl->vars->{user};
    }
}

# A sample controller for pages off /
{
    package My::App::Controller::Root;
    use Moo;
    extends 'My::App::Controller';

    sub index {
        my $controller = shift;
        return $controller->user;
    }
}

# A sample controller for pages off /user
{
    package My::App::Controller::User;
    use Moo;
    extends 'My::App::Controller';

    sub hello {
        my $controller = shift;
        return $controller->user;
    }
}

# A sample D2 app
{
    package My::App::Routes::Base;
    use Dancer2x::Tango;

    get '/test1' => to('root#index');
    get '/test2' => to('root');
}

# A second sample D2 app
{
    package My::App::Routes::User;
    use Dancer2x::Tango;

    # /user/test3
    get '/test3' => to('user#hello');
}


## Plack::Builder is really only here to demonstrate this is how multiple apps
## should be split and recombined
use Plack::Builder;
use Plack::Test;
use HTTP::Request::Common;
use Test::More;
use Test::Warnings;

my $app = builder {
    mount '/user' => My::App::Routes::User->to_app;
    mount '/'     => My::App::Routes::Base->to_app;
};

my $test = Plack::Test->create($app);

my $res = $test->request(GET '/test1');
is($res->decoded_content, 'Bob Cat', 'Get content back');

$res = $test->request(GET '/test2');
is($res->decoded_content, 'Bob Cat', 'Get content back');

$res = $test->request(GET '/user/test3');
is($res->decoded_content, 'Bob Cat', 'Get content back');

done_testing();
