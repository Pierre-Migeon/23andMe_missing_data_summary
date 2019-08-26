#!/usr/bin/perl -w
use strict;

#Description: outputs a table of the number of intersecting genes that are within a range such that I can look at the range with the least amount of genes for the purposes of easier debugging. 
#usage: perl genes_per_range.pl

printf ( "\n\n   Bin\t\tgenes\n" );
printf ( "  --------------------\n");

open ( IN, '<', "./correctness_summary.txt" );
while ( <IN> ) {
	chomp;
	`cat ../../../../ranges.bed | grep $_ > test.bed`;
	open(IN2, '<', "./test.bed");
	my @line = split(/\t/, (readline IN2));
	close IN2;
	$line[0] =~ s/([0-9]+)_[0-9]+/$1/;
	my $line = join("\t", @line);
	open(my $fh, '>', "./test.bed");
	print $fh $line;
	close $fh;
	my $num = `bedtools intersect -a test.bed -b ../../../../coordinate_convert/ref_ref_GRCh37.p10_top_level.gff3 | wc -l`;
	`bedtools intersect -a test.bed -b ../../../../coordinate_convert/ref_ref_GRCh37.p10_top_level.gff3 > $_.bed`;
	printf ( "   %-6s\t%-2i\n", $_, $num);
}	
printf("\n\n");
