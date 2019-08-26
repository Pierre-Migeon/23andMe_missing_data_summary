#!/usr/bin/perl -w
use strict;

#description: wraps the bedtools checker pipeline, which checks the calculated density of each gene annotation category against that of the bedtools calculated densities. Use one for checking against the real GTF calculated values and 2 for checking against the synthetic data.
#Usage: perl wrapper.pl [ 1 | 2 ] 

my $param = $ARGV[0];

if ($param == 1) {
	open(DATAFILE, '<', "../../../data.summary.txt");
} else {
	open(DATAFILE, '<', "../trial_run/data.summary2.txt");
}
my $firstline = readline DATAFILE;
chomp $firstline;
my @header = split(/\t/, $firstline);
for (my $i = 7; $i < @header - 1; $i++) {
	`bash ./test_density.sh $header[$i] $param`;
}
