#!/usr/bin/perl -w
use strict;

open(IN, '<', "../maxrange_37.p10.txt");
while(<IN>) {
	unless ($_ =~ m/#/) {
		chomp;
		my @line = split(/\t/, $_);
		print "echo 'The chromosome is $line[0]'\n";
		my $coordinate = $line[1];
		print "cat ./ref_GRCh37.p10_top_level.gff3 | grep $coordinate | grep \\#\\#\n";
	}
}
