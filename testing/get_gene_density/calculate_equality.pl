#!/usr/bin/perl -w
use strict;

#Description: Checking for trends between the bedtools verified density calculations and the inconsistent density calculations on the basis of total gene density being the sum of the other densities, to assist in narrowing down bugs.
#Usage: perl calculate_equality.pl correct_or_incorrect.txt

####################################################
### Read in the data summary file and compare it ###
####################################################
my $density_stats = $ARGV[0];
my @density_sum_stat = (0,0);

open(DATAFILE, '<', $density_stats);
while(<DATAFILE>) {
	chomp;
	my @line = split('\t', $_);
	my $sum = 0;
	my $density = $line[7];
	for (my $i = 8; $i < @line - 1; $i++) {
		$sum += $line[$i];
	}
	if ($sum == $density) {
		$density_sum_stat[0]++;
	} else {
		$density_sum_stat[1]++
	}
	print "There were $density_sum_stat[0] bins for which the total density was equal to the sum of the parts and $density_sum_stat[1] bins where it was not\n";
}
close(DATAFILE);
