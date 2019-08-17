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
	}
}
close(BED);
# Open new SNPs file 
open( my $fh, '>', "./SNPs_binned.txt" );
############################################
# Read in the SNPs and reformat and print: #
############################################
open(SNP, '<', $inSNPs);
my $i = 0;
print "Reading in and binning the SNPs";
while(<SNP>) {
	if ( $_ =~ m/^#/ ) {
		print $fh $_;
	} else {
	chomp;
	my @line = split(/\t/, $_);
	$line[1] = find_bin($line[2], %{$ranges{$line[1]}});
	print $fh join("\t", @line) . "\n";
	}
	if ($i == 1) {
		print "\033[1A\033[4D";
	} elsif( $i == 100 ) { 
		print ".";
	} elsif( $i == 200 ) {
		print ".";
	} elsif( $i == 300 ) {
		print ".\n";
	} elsif( $i == 400 ) {
		print "\033[1A";
	} elsif ( $i == 500 ) {
		print "   \n";
		$i = 0;
	}
	$i++;
}	

print "Done!\n";

#Subroutine to find the appropriate bin for the SNP coordinate:
sub find_bin {
	my ($coordinate) = shift;
	my %startend = @_;
	foreach(keys %startend) {
		if (${$startend{$_}}[0] <= $coordinate && ${$startend{$_}}[1] > $coordinate) {
			return( $_ );
		}
	}
}
