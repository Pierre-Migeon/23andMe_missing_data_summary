#!/usr/bin/perl -w 
use strict;

#Description: This script reads the GTF file and outputs a bedfile of the limits of the annotated range for the chromosomes. Requires the presence of GTF file in the same directory and outputs to maxrange.bed
#Usage: perl true_chr_limits.pl

my %highest_range;
my @chromosomes;
open(IN, '<', "./Homo_sapiens.GRCh38.97.gtf");
while(<IN>) {
	unless ($_ =~ '^#') {
		my @line = split('\t', $_);
		if (defined ($highest_range{$line[0]})) {
			if ($line[4] > $highest_range{$line[0]}) {
				$highest_range{$line[0]} = $line[4];
			}
		} else { 
			$highest_range{$line[0]} = $line[4];
			push @chromosomes, $line[0];
		}
	}
}

#Open and print the total range for the chromosome (well, from start to max annotated range)
open (my $fh, '>', "./maxrange.bed");
print $fh "#Chromosome\tstart\tend\n";
foreach (@chromosomes) {
	unless ($_ =~ m/[KG]/) {
		print $fh "$_\t0\t$highest_range{$_}\n";
	}
}
