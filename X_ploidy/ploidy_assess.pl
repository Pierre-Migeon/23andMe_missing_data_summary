#!/usr/bin/perl -w
use strict;
###################################################################################
#  Description: Performs calculations of haploid vs diploid calls for the genome  #
# 	and outputs summary table showing these statistics for the Automosomes    #
#	vs the X and Y chromosomes and MT genome. Includes I and D calls.	  #
#										  #
#  Usage: perl ploidy_assess.pl my_genome_file.txt				  #
###################################################################################
my $inSNPs = $ARGV[0];
my %stats;

#initialize these to zero. Could probably do this in a better way, like set to zero 
#if not defined in the printf statements, but lazy for now. The whole thing could be 
#rewritten for the sake of conciseness and I may just get around to doing so. Data first...
$stats{'Autosomes'}{'diploid'} = 0;
$stats{'Autosomes'}{'haploid'} = 0;
$stats{'Autosomes'}{'insertion'} = 0;
$stats{'Autosomes'}{'deletion'} = 0;

my $i = 0;
my $last_one = 0;
my $switch = 0;
open(SNP, '<', $inSNPs);
while(<SNP>) {
	unless ( $_ =~ m/^#|--/ ) {
		chomp;
		my @line = split(/\t/, $_);
		#If it's allomsomal or MT
		if ($line[1] =~ m/X|Y|MT/) {
			#intialize values to zero
			if (!defined($stats{$line[1]})) {
                        	$stats{$line[1]}{'diploid'} = 0;
                        	$stats{$line[1]}{'haploid'} = 0;
				$stats{$line[1]}{'insertion'} = 0;
				$stats{$line[1]}{'deletion'} = 0;
			}
			#if it's a diploid elsif a haploid call set:
			if ($line[3] =~ m/[ATCGID][ATCGID]/) {
				$stats{$line[1]}{'diploid'}++;
			} elsif ($line[3] =~ m/[ATCGID]/) {
				$stats{$line[1]}{'haploid'}++;
			}
			if ($line[3] =~ m/[I]/) {
				$stats{$line[1]}{'insertion'}++;
			} 
                        if ($line[3] =~ m/[D]/) {
				$stats{$line[1]}{'deletion'}++;
                        }
		#if it's non-allosomal:
		} else {
			#Diploid elsif haploid:
			if ($line[3] =~ m/[ATCGID][ATCGID]/) {
				$stats{'Autosomes'}{'diploid'}++;
                        } elsif ($line[3] =~ m/[ATCGID]/) {
				$stats{'Autosomes'}{'haploid'}++;
			}
			#Count number of insertions:
			if ($line[3] =~ m/[I]/) {
                                $stats{'Autosomes'}{'insertion'}++;
                        } 
			#Count number of deletions
                        if ($line[3] =~ m/[D]/) {
                                $stats{'Autosomes'}{'deletion'}++;
                        }
		}
	}
}


printf ("\n\n\n\t\t\t\t X \t Y\tMT\tAutosomes\n");
printf ("\t\t\t\t----------------------------------\n");
printf ("\t\tHaploid calls:   %d \t %d\t%d\t%d   \n", $stats{'X'}{'haploid'}, $stats{'Y'}{'haploid'}, $stats{'MT'}{'haploid'}, $stats{'Autosomes'}{'haploid'});
printf ("\t\tDiploid calls:   %d \t %d\t%d\t%d   \n", $stats{'X'}{'diploid'}, $stats{'Y'}{'diploid'}, $stats{'MT'}{'diploid'}, $stats{'Autosomes'}{'diploid'});
printf ("\t      Insertion calls:   %d \t %d\t%d\t%d   \n", $stats{'X'}{'insertion'}, $stats{'Y'}{'insertion'}, $stats{'MT'}{'insertion'}, $stats{'Autosomes'}{'insertion'});
printf ("\t       Deletion calls:   %d \t %d\t%d\t%d   \n", $stats{'X'}{'deletion'}, $stats{'Y'}{'deletion'}, $stats{'MT'}{'deletion'}, $stats{'Autosomes'}{'deletion'});
printf ("\n\n");

