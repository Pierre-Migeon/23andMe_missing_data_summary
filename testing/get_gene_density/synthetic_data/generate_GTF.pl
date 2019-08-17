#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#Completely basic mode: Outputs non-intersecting genes that don't span any of the bins.
#Basic mode: Outputs non-intersecting genes that intersect with the bins 
#Full mode: Outputs intersecting genes that intersect with the bins
#Advanced mode: Outputs intersecting genes that intersect with the bins and includes multiple levels of intersection

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
my @chromosomes;
my %ranges;
open(IN, '<', "maxrange_37.p10.txt");
while(<IN>) {
	unless ($_ =~ m/^#/) {
		chomp;
		my @line = split(/\t/, $_);
		push @chromosomes, $line[0];
		$ranges{$line[0]}[0] = 0;
		$ranges{$line[0]}[1] = $line[1];
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

#Open the file for printing the synthetic GTF data
##################################################
open(my $fh_gtf, '>', "./synthetic.Homo_sapiens.GRCh38.97.gtf");

#generate ranges for each of the chromosomes
############################################
my %density;
foreach (@chromosomes) {
	my $chr = $_;
	my $i = $ranges{$chr}[0];
	while($i < $ranges{$chr}[1]) {
		my $distance = int(rand(5000)) + 500;
		my $gene_length = int(rand(10000)) + 500;
		#adjust chromosome name
		$GTFline[0] = $chr;
		$i += $distance;
		$GTFline[3] = $i;
		$i += $gene_length;
		$GTFline[4] = $i;
		my @name = split(/;/, $GTFline[8]);
		for(int(rand(@genetypes - 1))) {
			$name[@name - 2] = "gene_biotype \"$genetypes[$_]\"";			
		}
		$GTFline[8] = join(";", @name);
		$density{$chr} += $GTFline[4] -  $GTFline[3] + 1;
		my $out = join("\t", @GTFline);
		unless ($i > $ranges{$chr}[1]) {
			print $fh_gtf $out;
		}
	}
}

#Open density outfile
#####################
open(my $fh_d, '>', "./density.txt");
print $fh_d "#Chromosome\tdensity\n";

#Calculate the density for each range and output data
#####################################################
foreach (@chromosomes) {
	my $chr = $_;
	$density{$chr} /= $ranges{$chr}[1] - $ranges{$chr}[0];
	print $fh_d "$chr\t$density{$chr}\n";
}



	#my @name = split(/;/, $line[8]);
	#$name[@name - 1] =~ s/.*"(.*)".*/$1/;



