#!/usr/bin/perl -w
use strict;

my @array = (1,2,3,4,5,6,7,8,9);

print "Before: @array.\n";

mod_array( \@array );

print "After:  @array.\n";

sub mod_array {
    my( $arrayref ) = $_[0];

    @$arrayref = reverse( @$arrayref );
}


