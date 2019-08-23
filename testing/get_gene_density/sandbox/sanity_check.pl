#!/usr/bin/perl -w 
use strict;


my $datafile = $ARGV[0];

open(IN, '<', $datafile);
while (<IN>) {
	unless ($_ =~ m/^Chromosome/) {
		my $current = $_;
		chomp;
		my @line = split(/\t/, $_);
		for (7..(@line -1)) {
			if ($line[$_] == 1) {
				print $current . "\n";
			}
			if ($line[$_] == 1 && $line[7] != 1) {
				print "OH NO! It appears that there is an inconsistency!!!\n";
			}
		}
	}
}
