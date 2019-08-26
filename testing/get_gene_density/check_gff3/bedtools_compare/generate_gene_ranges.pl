#!/usr/bin/perl -w
use strict;

#Description: generates a bedfile of the start and end for each gene on each chromosome:
#Usage: perl generate_gene_ranges.pl
#To do: update to make it per gene annotation

my $annotation = $ARGV[0];
open (IN, '<', "./../../../../coordinate_convert/ref_ref_GRCh37.p10_top_level.gff3");
while (<IN>) {
	unless ($_ =~ m/^#|^N[CTW]/) {
		my @line = split('\t', $_);
		if ($annotation eq "gene_density") {
			if ($line[2] eq "gene") {
				$line[3]--;
				print "$line[0]\t$line[3]\t$line[4]\n";
			}
		}
	}
}
