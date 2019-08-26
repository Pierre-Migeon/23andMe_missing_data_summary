#!/usr/bin/perl -w
use strict;

#Description: This script subsamples the gtf file so that I can post it to my github for other people to play with. The fill file is too big to be uploaded to github.


my @chromosomes;
my $i = 0;
open(IN, '<', "./data.summary.txt");
while(<IN>) {
	unless ($_ =~ m/Chromosomes/)
	{
		my @line = split('\t', $_);
		push @chromosomes, $line[0];
		$i++;
	}
}
$i--;

for(0..$i) {
	`cat Homo_sapiens.GRCh38.97.gtf | grep ^$chromosomes[$_] | head -6001 >> Homo_sapiens.GRCh38.97.subsample.gtf`;
}


