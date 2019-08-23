#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#Completely basic mode: Outputs non-intersecting genes that don't span any of the bins. (input 0)
#Basic mode: Outputs non-intersecting genes that intersect with the bins (input 1)
#Full mode: Outputs intersecting genes that intersect with the bins (input 2)
#Advanced mode: Outputs intersecting genes that intersect with the bins and includes multiple levels of intersection (input 3)

my $difficulty = $ARGV[0];

#Read in gene types
###################
my @genetypes;
open(IN, '<', "./gene_types.txt");
while(<IN>) {
		chomp;
		push @genetypes, $_;
}
close(IN);

#Read in the chromosomes
########################
my @bins;
my %density;
my %ranges;
open(IN, '<', "ranges.bed");
while(<IN>) {
	unless ($_ =~ m/^#/) {
		chomp;
		my @line = split(/\t/, $_);
		push @bins, $line[0];
		$ranges{$line[0]}[0] = $line[1];
		$ranges{$line[0]}[1] = $line[2];
		$density{$line[0]} = 0;
	}
}
close(IN);

#read in the subsampled GTF
###########################
my @GTFline;
open(IN, '<', "./Homo_sapiens.GRCh38.97.subsample.gtf");
while(<IN>) {
	my @line = split(/\t/, $_);
	if ($line[2] eq "gene") {
		@GTFline = @line;
	}
}
close(IN);

#Open the file for printing the synthetic GTF data
##################################################
open(my $fh_gtf, '>', "./synthetic.Homo_sapiens.GRCh38.97.gtf");

#generate ranges for each of the chromosomes
############################################
my $last_chr = 0;
my $switch = 0;
my $rand = 0;
foreach (@bins) {
	my $out;
	my $bin = $_;
	my $i = $ranges{$bin}[0] + 600;
	if ($difficulty > 0 && prefix($bin) eq $last_chr && $switch == 1 && $rand != 1) {
		$density{$bin} += 100;
		$switch = 0;
	}
	while($i < $ranges{$bin}[1] - 600) {
		#genes at least ~1 kb apart at most 201 kb or at least 50 bp apart at most 1 kb apart for mitochondria
		my $distance = ($bin =~ m/MT/) ? int(rand(950)) + 50 : int(rand(200000)) + 1000;
		#genes at least 500 bp at most 5.5 kb or at least 300 bp at most 1 kb mitochondria
		my $gene_length = ($bin =~ m/MT/) ? int(rand(700)) + 300 : int(rand(5000)) + 500;
		#adjust chromosome name
		$GTFline[0] = prefix($bin);
		$i += $distance;
		$GTFline[3] = $i;
		$i += $gene_length;
		$GTFline[4] = $i;
		my @name = split(/;/, $GTFline[8]);
		for(int(rand(@genetypes - 1))) {
			$name[@name - 2] = " gene_biotype \"$genetypes[$_]\"";
		}
		$GTFline[8] = join(";", @name);
		if ($i < $ranges{$bin}[1] - 600) {
			#1/3 of the time have a gene that is overlapping before 
			$rand = int(rand(3));
			if ($rand == 1 && $difficulty > 2 && $bin !~ m/MT/) {
				$GTFline[3] -= 400;
				$GTFline[4] -= 400;
				$out = join("\t", @GTFline);
                                print $fh_gtf $out;
                                $density{$bin} += 400;
				$GTFline[3] += 400;
                                $GTFline[4] += 400;
			}
			$out = join("\t", @GTFline);
			$density{$bin} += $GTFline[4] -  $GTFline[3] + 1;
			print $fh_gtf $out;
			#1/4 of the time, add in an intersecting bin
			$rand = int(rand(4));
			if ($rand == 1 && $difficulty > 1 && $bin !~ m/MT/) {
				$GTFline[3] += 150;
				$GTFline[4] += 150;
				$out = join("\t", @GTFline);
				print $fh_gtf $out;
				$density{$bin} += 150;
			}
		}
	}
	#~4/5 of the time, add in a bin-intersecting gene.
	$rand = int(rand(5));
	if($difficulty > 0 && $bin !~ m/MT/ && $rand != 1) {
		$GTFline[3] = $ranges{$bin}[1] - 400;
		$GTFline[4] = $ranges{$bin}[1] + 100;
		$density{$bin} += 401;
		$out = join("\t", @GTFline);
		$switch = 1;
		print $fh_gtf $out;
	}
	$last_chr = prefix($bin);
}

#Open density outfile
#####################
open(my $fh_d, '>', "./density.txt");
print $fh_d "#Chromosome\tdensity\n";

#Calculate the density for each range and output data
#####################################################
foreach (@bins) {
	my $bin = $_;
	$density{$bin} /= $ranges{$bin}[1] - $ranges{$bin}[0] + 1;
	print $fh_d "$bin\t$density{$bin}\n";
}

#######################################
### Subroutine to return the prefix ###
#######################################
sub prefix {
	my $word = shift;
	$word =~ s/([0-9A-Z]+)_[0-9]+/$1/;
	return ($word);
}
