#!/usr/bin/perl -w
use strict;

##################################################################################
#										 #
#  Description: Takes as input binned 23andme data file, and computes statistics #
#   regarding per bin SNP statistics and missing data statistics, in  	  	 #
#    terms of a binned genome.							 #
#										 #
#  Usage : perl missing_data.pl 23andme_binned_file.txt				 #
# 										 #
##################################################################################
#######################
my $snps = $ARGV[0];
my $missing_count = 0;
my $total_count = 0;
my %missing_by_chr;
my @bins;
################
#####################################
# Internal Dictionary of variables  #
#####################################
#index and corresponding contents:
#$missing_by_chr{"BIN ID"}[0] = total snps assayed per chromosome
#$missing_by_chr{"BIN ID"}[1] = total missing snps for the chromosome
#$missing_by_chr{"BIN ID"}[2] = length of range over which snps are assayed for each chromosome
#####################################
#$*$*$*$*$*$*$*$*$*$*$*$*$*$*$*$*$*$
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
####################################################
# Read in and store bin sizes from the ranges file #
####################################################
open(IN, '<', "./ranges.bed");
while(<IN>) {
	unless ($_ =~ m/^#/) {
		chomp;
		my @line = split(/\t/, $_);
		$missing_by_chr{$line[0]}[2] = $line[2] - $line[1]; 
	}
}

#######################################################
# Read in and store base statistics from the SNP file #
#######################################################
#////////////////////
open(IN, '<', $snps);
while(<IN>)
{
	unless($_ =~ '^#') {
		my @line = split('\t', $_);
		if (!defined($missing_by_chr{$line[1]}[0])) {
			push @bins, $line[1];
			$missing_by_chr{$line[1]}[0] = 0;
			$missing_by_chr{$line[1]}[1] = 0;
		}
		if ($line[3] =~ m/--/) {
			$missing_by_chr{$line[1]}[1]++;
			$missing_count++;
		}
		$missing_by_chr{$line[1]}[0]++;
		$total_count++;
	}
}
close (IN);
######################################
# Output tab delimited table of data #
######################################
open(my $fh, '>', "./data.summary.txt");
print $fh "Chromosome\tRange\tSNPs\tSNP_density\tMissing\tpercent_missing\tMissing_density\n";
foreach (@bins) {
	print $fh "$_\t$missing_by_chr{$_}[2]\t$missing_by_chr{$_}[0]\t" . ($missing_by_chr{$_}[0] / $missing_by_chr{$_}[2]) . "\t$missing_by_chr{$_}[1]\t" . (($missing_by_chr{$_}[0] == 0 ) ? 0 : ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[0])) . "\t" . ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[2]) . "\n";
}
close ($fh);
