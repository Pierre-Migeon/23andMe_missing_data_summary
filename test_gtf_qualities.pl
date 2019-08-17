#!/usr/bin/perl -w
use strict;

#Description: Code to test characteristics of the GTF file to ensure that our assumptions about the file format are correct. 
#For instance that the starts of the genes are in consecutive order in the gtf file:

#Usage: perl test_gtf_qualities.

my $last_chromosome = 1;
my $last_start = -1;
my $line = 0;
open (IN, '<', "./Homo_sapiens.GRCh38.97.gtf");
while (<IN>) { 
	unless ($_ =~ '^#') {
		my @line = split('\t', $_);
		if ($line[2] eq "gene") { 
			unless ($last_start == -1 || $line[0] ne $last_chromosome) {
				if ($line[3] < $last_start) {
					print "A NON-CONSECUTIVENESS HAS BEEN DISCOVERED!!!!\n";	
				}
			}
			$last_chromosome = $line[0];
			$last_start = $line[3];
		}
	}
}
