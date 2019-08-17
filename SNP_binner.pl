#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#######################################################################################
# Description: Reads in 23andMe SNP file and binned bedfile and assigns SNPs to bins. #
#										      #
#  Usage: perl SNP_binner.pl genome_file.txt	   		 		      #
#										      #
#######################################################################################
my $inSNPs = $ARGV[0];
my %ranges;
my $base_chr;
#read in the bedfile of ranges and store them in a hash
open(BED, '<', "./ranges.bed");
print "Reading in the BEDfile...\n";
while(<BED>) {
	unless( $_ =~ m/^#/ ) {
		chomp;
		my @line = split(/\t/, $_);
		($base_chr) = $line[0] =~ /([0-9A-Z]+)/;
		${$ranges{$base_chr}{$line[0]}}[0] = $line[1];
		${$ranges{$base_chr}{$line[0]}}[1] = $line[2];
		#${$ranges{$base_chr}{'last_bin'}}[0] = $line[0];
	}
}
close(BED);
# Open new SNPs file 
open( my $fh, '>', "./SNPs_binned.txt" );
############################################
# Read in the SNPs and reformat and print: #
############################################
open(SNP, '<', $inSNPs);
print "Reading in and binning the SNPs...\n";
while(<SNP>) {
	if ( $_ =~ m/^#/ ) {
		print $fh $_;
	} else {
	chomp;
	my @line = split(/\t/, $_);
	$line[1] = find_bin($line[2], %{$ranges{$line[1]}});
	print $fh join("\t", @line) . "\n";
	}
}	

print "Done!\n";

#Subroutine to find the appropriate bin for the SNP coordinate:
sub find_bin {
	my ($coordinate) = shift;
	my %startend = @_;
	foreach (keys %startend) {
		#if ($coordinate == ${$startend{${$startend{'last_bin'}}[0]}}[1]) {
		#	return (${$startend{'last_bin'}}[0]);
		#}
		unless ($_ =~ m/last/) {
			if (${$startend{$_}}[0] <= $coordinate && ${$startend{$_}}[1] > $coordinate) {
				return ($_);
			}
		}
	}	
}
