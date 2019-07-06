#!/usr/bin/perl -w
use strict;
use Data::Dumper;


my @array = qw("1", "3", "4", "5");

print Dumper(@array);


splice @array, 1, 0, '2';

print Dumper(@array);
