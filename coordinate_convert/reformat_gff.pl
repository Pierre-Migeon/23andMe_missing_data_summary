#!/usr/bin/perl -w
use strict;

#Description: reformats gff file to change superscaffold names to the corresponding chromosome names
#Usage: perl reformat_gff.pl

my %genes;
open(IN, '<', "./ref_GRCh37.p10_top_level.gff3");
while(<IN>) {
	unless ($_ =~ m/^#/) {
		my @line = split(/\t/, $_);
		if ($line[2] eq "gene") {
			if ($line[0] eq "NC_012920.1") {
				$line[0] = "MT";
			} elsif ($line[0] eq "NC_000023.10") {
				$line[0] = "X";
			} elsif ($line[0] eq "NC_000024.9") {
				$line[0] = "Y";
			} else {
				$line[0] =~ s/NC_0+([1-9]+)\.[0-9]+/$1/;
			}
			my $line = join("\t", @line);
			print $line;
		}
	}
}
