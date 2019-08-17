#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#Description: Reads in a merged bedfile of genic ranges per 
#Usage: perl density_per_bin.pl merged.bed bin_ranges.bed

my $mergedbed = $ARGV[0];
my $binranges = $ARGV[1];

my %genes;
my $binsize = 0;
open(IN, '<', $mergedbed);
while (<IN>) {
	chomp;
	my @line = split(/\t/, $_);
	push @{$genes{$line[0]}}, $line[1], $line[2];	
}
close (IN);

#Read in the binned ranges:
my %bincoverage;
my @bins;
open(IN, '<', $binranges);
while (<IN>) {
	unless ($_ =~ m/^#/) {
		chomp;
		my @line = split(/\t/, $_);
		if ($binsize == 0) {
			$binsize = $line[2] - $line[1];
        	}
		push @bins, $line[0];
		my $chr = prefix($line[0]);
		$bincoverage{$line[0]} = 0;
		if (defined($genes{$chr})) {
			for (my $i = 0; $i < @{$genes{$chr}} - 1; $i += 2) {
				unless ($genes{$chr}[$i] > $line[2] || $genes{$chr}[$i + 1] < $line[1]) {
					my @coordinates = ($genes{$chr}[$i], $genes{$chr}[$i + 1], $line[1], $line[2]);
					@coordinates = sort {$a <=> $b} @coordinates;
					$bincoverage{$line[0]} += $coordinates[2] - $coordinates[1] + 1;
				}
			}
		}
	}
}

my $density;
foreach (@bins) {
	if ($_ eq "MT_0") {
		$density = $bincoverage{$_} / 16547;
	} else {
		$density = $bincoverage{$_} / $binsize;
	}
	print "$_\t$density\n";
}

#######################################
### Subroutine to return the prefix ###
#######################################
sub prefix {
	my $word = shift;
	$word =~ s/([0-9A-Z]+)_[0-9]+/$1/;
	return ($word);
}

