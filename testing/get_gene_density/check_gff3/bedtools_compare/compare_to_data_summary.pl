#!/usr/bin/perl -w
use strict;

#Description: Tests each of the densities calculated using bedtools merge as the basis for the calculation and compares them to the densities calculated using my script. Throws an error message in the case that there is a difference between the two methods of calculation.
#Usage: perl compare_to_data_summary.pl "annotation name"

####################################################
### Read in the data summary file and compare it ###
####################################################
my %bedtools_density;
open(DENSITY, '<', "./density.txt");
while (<DENSITY>) {
	unless ($_ =~ m/^#/) {
		chomp;
		my @line = split(/\t/, $_);
		$bedtools_density{$line[0]} = $line[1];
	}
}
close(DENSITY);

####################################################
### Read in the data summary file and compare it ###
####################################################
my $annotation = $ARGV[0];
my $num;
my @header;
my @compare =(0,0);

open(DATAFILE, '<', "./../../../../data.summary.txt");
while(<DATAFILE>) {
	chomp;
	if ($_ =~ m/Chromosome/) {
		@header = split(/\t/, $_);
	} else { 
		if (!defined($num)) {
			for (my $i = 0; $i < @header; $i++) {
				if ($header[$i] eq $annotation) {
					$num = $i;
				}
			}
		}
		my @line = split('\t', $_);
		if ($line[$num] == $bedtools_density{$line[0]}) {
			$compare[0]++;
		} else {
			print "$line[0]\n";
			$compare[1]++;
		}
	}
}
close(DATAFILE);
