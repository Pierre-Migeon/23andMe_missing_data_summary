#!/usr/bin/perl -w
use strict;

open(DATAFILE, '<', "../../data.summary.txt");
my $firstline = readline DATAFILE;
chomp $firstline;
my @header = split(/\t/, $firstline);
for (my $i = 7; $i < @header - 1; $i++) {
	`bash ./test_density.sh $header[$i]`;
}
