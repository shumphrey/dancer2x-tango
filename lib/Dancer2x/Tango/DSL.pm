package Dancer2x::Tango::DSL;

use strict;
use warnings;
use Moo;
use Dancer2x::Tango::Dispatcher;

extends 'Dancer2::Core::DSL';

sub BUILD {
    my $dsl = shift;
    $dsl->register(to => 1);
}

sub to {
    my $dsl = shift;
    return Dancer2x::Tango::Dispatcher::to($dsl, @_);
}

=head1 NAME

Dancer2x::Tango::DSL

=cut

1;
