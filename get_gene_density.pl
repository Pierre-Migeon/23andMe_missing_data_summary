#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#Description: Reads in a GTF format file and a list of ranges and outputs gene density statistics for each of those ranges. Runs as a part of my 23andme analysis pipeline. Requires the presence of a human genome GFT file, a bedfile of the ranges from the 23andme analaysis (output from the missing_data.pl script), and a data summary file (also output from this script) that is subsequently appended to by the running of get_gene_density.pl. I'm using the newest available genome GTF file, which is for assembly 38, while 23andme data is for version 37. I am working on either finding the appropriate GTF file or converting the coordinates, but am using this as an approximation for the moment.

my %stats;
my @data_summary;

###########################
### Read in the Bedfile ###
###########################
open(RANGES, '<', "./ranges.bed");
while(<RANGES>) {
	unless ($_ =~ "^#") {
		chomp;
		my @line1 = split('\t', $_);
		$stats{$line1[0]}{'start'} = $line1[1];
		$stats{$line1[0]}{'end'} = $line1[2];
	}
}
close(RANGES);
############################
### Read in the GFT file ###
############################
my @name;
my %gene_types;
open(IN, '<', "./Homo_sapiens.GRCh38.97.gtf");
while(<IN>) {
	unless ($_ =~ '^#') {
		my @line2 = split('\t', $_);
		#if it's a gene:
		if ($line2[2] =~ m/gene/) {
			#If it's one of the chromosomes that we are looking at (exludes rando scaffolds for instance):
			if (defined($stats{$line2[0]})) {
				#If it fits within the assayed range:
				if ($line2[3] >= $stats{$line2[0]}{'start'} && $line2[4] <= $stats{$line2[0]}{'end'}) {
					$stats{$line2[0]}{'count'}++;
					@name = split(/;/, $line2[8]);
					$name[@name - 2] =~ s/.*"(.*)".*/$1/;
					$stats{$line2[0]}{$name[@name - 2]}++;
					$gene_types{$name[@name - 2]} = 1;
				}
			}
		}
	}
}
close(IN);
my @gene_types = keys %gene_types;
@gene_types = sort { $a cmp $b } @gene_types;
##################################
### Calculate the gene density ###
##################################
foreach( sort keys %stats ) {
	my $chr = $_;
	$stats{$chr}{'density'} = $stats{$chr}{'count'} / ($stats{$chr}{'end'} - $stats{$chr}{'start'});
	foreach(@gene_types) {
		if (defined( $stats{$chr}{$_} )) {
			$stats{$chr}{$_} = $stats{$chr}{$_} / ($stats{$chr}{'end'} - $stats{$chr}{'start'});
		} else {
			$stats{$chr}{$_} = 0;
		}
	}
}
unshift @gene_types, "Overall_gene_density";
##################################################
### Read in the data summary file and store it ###
##################################################
my $i = 0;
my @header;
open(DATAFILE, '<', "./data.summary.txt");
while(<DATAFILE>) {
	chomp;
	if ($_ =~ m/Chromosome/) {
		@header = split(/\t/, $_);
		}
	unless ($_ =~ m/Chr/ ) {
		my @line3 = split('\t', $_);
		$data_summary[$i] = \@line3; 
		$i++;
	}
}
close(DATAFILE);
push @header, @gene_types;
shift @gene_types;
my $header = join("\t", @header);
##################################################################
### Output the data summary with the added gene density column ###
##################################################################
my $chr_count = (scalar keys %stats);
my $line;
open(my $fh, '>', "./data.summary.txt");
print $fh $header . "\n"; 
for( $i = 0; $i < $chr_count; $i++ ) {
	push @{$data_summary[$i]}, $stats{$data_summary[$i][0]}{'density'};
	foreach(@gene_types) {
		push @{$data_summary[$i]}, $stats{$data_summary[$i][0]}{$_};
	}
	$line = join("\t", @{$data_summary[$i]});
	print $fh $line . "\n";
}
close $fh;
