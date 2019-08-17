#!/usr/bin/perl -w
use strict;

#Description: generates a bedfile of the start and end for each gene on each chromosome:
#Usage: perl generate_gene_ranges.pl
#To do: update to make it per gene annotation

my $annotation = $ARGV[0];
open (IN, '<', "./Homo_sapiens.GRCh38.97.gtf");
while (<IN>) {
	unless ($_ =~ '^#') {
		my @line = split('\t', $_);
		if ($annotation eq "Overall_gene_density") {
			if ($line[2] eq "gene") {
				print "$line[0]\t$line[3]\t$line[4]\n";
			}
		}
		elsif ($_ =~ $annotation && $line[2] eq "gene") {
			print "$line[0]\t$line[3]\t$line[4]\n";
		}
	}
}
