#!/usr/bin/perl
use strict;
use Math::Round;
use Data::Dumper;
######################
my $snps = $ARGV[0];
my $missing_count = 0;
my $total_count = 0;
my %missing_by_chr;

###
#TO DO:
# What is the correlation between gene density and marker density?
# 
#
#####################################
# Internal Dictionary of variables  #
#####################################
#index and corresponding contents:
#$missing_by_chr{$line[1]}[0] = total snps assayed per chromosome
#$missing_by_chr{$line[1]}[1] = total missing snps for the chromosome
#$missing_by_chr{$line[1]}[2] = coordinates of last snp in the chromosome
#$missing_by_chr{$line[1]}[3] = coordinates of the first snp in the chromosome
#$missing_by_chr{$line[1]}[4] = length of range over which snps are assayed for each chromosome
#$missing_by_chr{'sum_length'} = the sum of the length of the assayed ranges for each chromosome
#$missing_count = number of missing snps
#$total_count = number of snps in the data
#$chromosome_count = the number of chromosomes assayed in the data (variable unused for now)
#####################################
#$*$*$*$*$*$*$*$*$*$*$*$*$*$*$*$*$*$
#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
#######################################################
# Read in and store base statistics from the SNP file #
#######################################################
#////////////////////
open(IN, '<', $snps);
while(<IN>)
{
	unless($_ =~ '^#') {
		my @line = split('\t', $_);
		if((!defined($missing_by_chr{$line[1]})) || eof) {
			if (!defined($missing_by_chr{$line[1]})) { $missing_by_chr{$line[1]}[3] = $line[2]; }
			if (eof) { $missing_by_chr{$line[1]}[2] = $line[2]; }
			if (defined($missing_by_chr{'last chr'})) { $missing_by_chr{$missing_by_chr{'last chr'}}[4] = $missing_by_chr{$missing_by_chr{'last chr'}}[2] - $missing_by_chr{$missing_by_chr{'last chr'}}[3]; }
		}
		if ($line[3] =~ m/--/) {
			$missing_by_chr{$line[1]}[1]++;
			$missing_count++;
		}
		$missing_by_chr{$line[1]}[0]++;
		$missing_by_chr{$line[1]}[2] = $line[2];
		$missing_by_chr{'last chr'} = $line[1];
		$total_count++;
	}
}

my $chromosome_count = 0;
#calculate the sum of the ranges and the densities:
foreach( keys %missing_by_chr) {
	unless($_ =~ m/last|sum/) {
		#Sum of assayed ranges for each chromosome
		$missing_by_chr{'sum_length'} += $missing_by_chr{$_}[4];
		$chromosome_count++;
	}
}

########################
# Density Calculations #
########################
#Calculate the density of missing data:
$missing_by_chr{'sum_density'} = ($missing_count / $missing_by_chr{'sum_length'});
#Calculate the snp density:
$missing_by_chr{'snp_density'} = $total_count / $missing_by_chr{'sum_length'};

#########################################
# Output bed file of the assayed ranges #
#########################################
open(my $fh1, '>', "./ranges.bed");
print $fh1 "#Chr\tstart\tend\n";
foreach(sort { $a <=> $b } keys(%missing_by_chr)) {
        unless($_ =~ m/[A-Z]|last|sum|density/) {
        print $fh1 "$_\t$missing_by_chr{$_}[3]\t$missing_by_chr{$_}[2]\n";
        }
}
foreach (sort { $a cmp $b } keys(%missing_by_chr)) {
        unless($_ =~ m/[1-9]|last|sum|density/) {
        print $fh1 "$_\t$missing_by_chr{$_}[3]\t$missing_by_chr{$_}[2]\n";
        }
}
close $fh1;

######################################
# Output tab delimited table of data #
######################################
open(my $fh2, '>', "./data.summary.txt");
print $fh2 "Chromosome\tRange\tSNPs\tSNP_density\tMissing\t%_missing\tMissing_density\n";
foreach(sort { $a <=> $b } keys(%missing_by_chr)) {
	unless($_ =~ m/[A-Z]|last|sum|density/) {
	print $fh2 "$_\t$missing_by_chr{$_}[4]\t$missing_by_chr{$_}[0]\t" . ($missing_by_chr{$_}[0] / $missing_by_chr{$_}[4]) * 100 . "\t$missing_by_chr{$_}[1]\t" . nearest(0.01, ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[0]) * 100) . "%\t" . ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[4]) . "\n";
	}
}
foreach (sort { $a cmp $b } keys(%missing_by_chr)) {
	unless($_ =~ m/[1-9]|last|sum|density/) {
	print $fh2 "$_\t$missing_by_chr{$_}[4]\t$missing_by_chr{$_}[0]\t" . ($missing_by_chr{$_}[0] / $missing_by_chr{$_}[4]) * 100 . "\t$missing_by_chr{$_}[1]\t" . nearest(0.01    , ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[0]) * 100) . "%\t" . ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[4]) . "\n";
	}
}
close $fh2;

#####################
# Print data tables #
#####################
#$$$$$$$$$$$$
##########
# Table 1 #
###########
#*********
print "\n\n";
print "\n\t\t\t    Table 1: Single Nucleotide Polymorphism (SNP) Marker and Assayed Range Summary Statistics\n\n\n";
print "\t\t\t\t\t    Chr          SNPs         Range(bp)     Density(SNPs/bp)\n";
print "\t\t\t\t\t    --------------------------------------------------------\n";
#Print the numeric chromosome rows
foreach(sort { $a <=> $b } keys(%missing_by_chr))
{
	unless($_ =~ m/[A-Z]|last|sum|density/)
	{
		printf("\t\t\t\t\t     %-2d          %-5d        %-10d    %-15.13f\n", $_, $missing_by_chr{$_}[0], $missing_by_chr{$_}[4], (($missing_by_chr{$_}[0] / $missing_by_chr{$_}[4])));
	}
}
#print the alphabetical chromosome / MT rows
foreach (sort { $a cmp $b } keys(%missing_by_chr))
{
        unless($_ =~ m/[1-9]|last|sum|density|MT/)
        {
		printf("\t\t\t\t\t     %-2s          %-5d        %-10d    %-15.13f\n", $_, $missing_by_chr{$_}[0], $missing_by_chr{$_}[4], (($missing_by_chr{$_}[0] / $missing_by_chr{$_}[4])));
        }
}
printf("\t\t\t\t\t     %-2s          %-5d        %-10d    %-15.13f\n", "MT", $missing_by_chr{'MT'}[0], $missing_by_chr{'MT'}[4], ($missing_by_chr{'MT'}[0] / $missing_by_chr{'MT'}[4]));
print "\t\t\t\t\t    --------------------------------------------------------\n";
print "\t\t\t\t\t    total:       $total_count       $missing_by_chr{'sum_length'}\n";
#Table summary:
printf("\n\n\t\t\t    The average SNP density was %.6f SNPs / basepair, or 1 SNP marker every %d basepairs.\n\t\t\t    There was 1 marker per %d bp for the mitochondria, making the mitochondrial SNP density \n\t\t\t    %.2f times greater than the average. The Y chromosome had the lowest marker density, with 1\n\t\t\t    marker every %d basepairs (%.1f times lower than the average density)", ($total_count / $missing_by_chr{'sum_length'}), ($missing_by_chr{'sum_length'} / $total_count), ($missing_by_chr{'MT'}[4] / $missing_by_chr{'MT'}[0]), (($missing_by_chr{'MT'}[0] / $missing_by_chr{'MT'}[4]) / ($total_count / $missing_by_chr{'sum_length'})), ($missing_by_chr{'Y'}[4] / $missing_by_chr{'Y'}[0]), (($missing_by_chr{'Y'}[4] / $missing_by_chr{'Y'}[0]) / ($missing_by_chr{'sum_length'} / $total_count)));
print "\n\n\n\n";
#********
#$$$$$$$$$
###########
# Table 2 #
###########
#$$$$$$$$$
#********
print "\t\t\t\tChr               Missing        %Missing       Range(bp)    Density(missing/bp)\n";
print "\t\t\t\t--------------------------------------------------------------------------------\n";
foreach(sort { $a <=> $b } keys(%missing_by_chr))
{
	unless($_ =~ m/[A-Z]|last|sum|density/)
	{
		printf("\t\t\t\t %-2d               %-4d           %#-4.2f%s%%         %-9d    %-18.12e\n", $_, $missing_by_chr{$_}[1], nearest(.01, ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[0]) * 100), (($missing_by_chr{$_}[1] / $missing_by_chr{$_}[0]) * 100 > 9) ? '' : '0', $missing_by_chr{$_}[4], ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[4]));
	}
}
foreach (sort { $a cmp $b } keys(%missing_by_chr))
{
	unless($_ =~ m/[1-9]|last|sum|density|MT/)
	{
		printf("\t\t\t\t %-2s               %-4d           %#-4.2f%s%%         %-9d    %-18.12e\n", $_, $missing_by_chr{$_}[1], nearest(.01, ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[0]) * 100), ((($missing_by_chr{$_}[1] / $missing_by_chr{$_}[0]) * 100 > 9) ? '' : '0'), $missing_by_chr{$_}[4], ($missing_by_chr{$_}[1] / $missing_by_chr{$_}[4]));
	}
}
printf("\t\t\t\t %2s               %-4d           %#-4.2f%s%%         %-9d    %-18.12e\n", "MT", $missing_by_chr{'MT'}[1], nearest(.01, ($missing_by_chr{'MT'}[1] / $missing_by_chr{'MT'}[0]) * 100), ($missing_by_chr{'MT'}[1] / $missing_by_chr{'MT'}[0]) * 100 > 9 ? '' : '0', $missing_by_chr{'MT'}[4], ($missing_by_chr{'MT'}[1] / $missing_by_chr{'MT'}[4]));
print "\t\t\t\t--------------------------------------------------------------------------------\n";
print "\t\t\t\ttotal:            " . $missing_count . "\t         " . nearest(0.01, ($missing_count / $total_count) * 100) . "%\t        " . $missing_by_chr{'sum_length'} . "\t" . "\n\n\n";
#Table summary:
printf("\n\t\t    %d out of %d total assayed SNP markers were missing, for a total of %3.2f%% missing data. %3.2f%% of all\n\t\t    missing data was found on the Y chromosome, w/ %3.2f%% of the assayed Y chromosome loci missing. Mitochondrial\n\t\t    missing data density was %d times higher than the average missing data density. The average missing data \n\t\t    density was %.6f SNPs / basepair, or 1 SNP marker every %d basepairs (1 missing SNP for every %d markers).\n\t\t    For the mitochondria, a missing marker was found about once every %d basepairs or once every %d markers (%d times\n\t\t    higher than the average # missing / marker). For the Y chromosome, a missing marker was found only every %d \n\t\t    basepairs, but 1 out of every ~%d markers was missing. The Y chromosome missing per assayed marker rate was %d \n\t\t    times higher than the average.\n\n", $missing_count, $total_count, nearest(.01, ($missing_count / $total_count) * 100), nearest(0.01, ($missing_by_chr{'Y'}[1] / $missing_count) * 100), nearest(0.01, $missing_by_chr{'Y'}[1] / $missing_by_chr{'Y'}[0] * 100), nearest(1.0, (($missing_by_chr{'MT'}[1] / $missing_by_chr{'MT'}[4]) / $missing_by_chr{'sum_density'})), $missing_by_chr{'sum_density'}, 1 / $missing_by_chr{'sum_density'}, (100 / (($missing_count / $total_count) * 100)), 1 / ($missing_by_chr{'MT'}[1] / $missing_by_chr{'MT'}[4]), (100 / (($missing_by_chr{'MT'}[1] / $missing_by_chr{'MT'}[0]) * 100)), nearest(1, (($missing_by_chr{'MT'}[1] / $missing_by_chr{'MT'}[0]) / ($missing_count / $total_count))), 1 / ($missing_by_chr{'Y'}[1] / $missing_by_chr{'Y'}[4]), (100 / (($missing_by_chr{'Y'}[1] / $missing_by_chr{'Y'}[0]) * 100)), nearest(1, (($missing_by_chr{'Y'}[1] / $missing_by_chr{'Y'}[0]) / ($missing_count / $total_count))));
