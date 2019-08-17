#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#Description: Reads in a GTF file and list of binned ranges and outputs gene density statistics for each of those bins. Requires the presence of a human genome GTF file, a bedfile of the ranges from the 23andme analaysis (output from missing_data_ranged.pl script), and data.summary.txt file to which this script appends. I'm using the newest available genome GTF file, which is for assembly 38, while 23andme data is for version 37. I am working on either finding the appropriate GTF file or converting the coordinates, but am using this as an approximation for the moment.

#Usage: perl get_gene_density.pl

my %stats;
my @data_summary;
my $base_chr;
my %gene_ranges;
###########################
### Read in the Bedfile ###
###########################
open(RANGES, '<', "./ranges.bed");
while(<RANGES>) {
	unless ($_ =~ "^#") {
		chomp;
		my @line1 = split(/\t/, $_);
		$base_chr = prefix($line1[0]);
		$stats{$base_chr}{$line1[0]}{'start'} = $line1[1];
		$stats{$base_chr}{$line1[0]}{'end'} = $line1[2];
	}
}
close(RANGES);
print "Reading and parsing the GTF...\n";
############################
### Read in the GTF file ###
############################
my @name;
my %gene_types;
my @chromosomes;
$chromosomes[0] = "1";
my $switch;
my $overlap_gene = 0;
my $overlap_specific = 0;
open (IN, '<', "./Homo_sapiens.GRCh38.97.gtf");
while (<IN>) {
	unless ($_ =~ '^#') {
		my @line2 = split('\t', $_);
		#if it's a gene:
		if ($line2[2] eq "gene") {
			#If it's one of the sequences that we are interested in (exluding rando scaffolds etc):
			if (defined($stats{$line2[0]})) {
				if ($line2[0] ne $chromosomes[@chromosomes - 1]) {
                        		push @chromosomes, $line2[0];
					$overlap_gene = 0;
					$overlap_specific = 0;
                		}
				$switch = 0;
				#Foreach bin of the current sequence:
				foreach (keys $stats{$line2[0]}) {
					#If it falls within the assayed range:
					unless ($line2[4] < $stats{$line2[0]}{$_}{'start'} || $line2[3] > $stats{$line2[0]}{$_}{'end'}) {
						#extract the gene type information
						@name = split(/;/, $line2[8]);
						$name[@name - 2] =~ s/.*"(.*)".*/$1/;
						if ($switch == 0 && defined($gene_ranges{$line2[0]}{'count'}) && @{$gene_ranges{$line2[0]}{'count'}} + 0 > 0 && defined($gene_ranges{$line2[0]}{$name[@name - 2]}) && @{$gene_ranges{$line2[0]}{$name[@name - 2]}} + 0 > 0) {
							$overlap_gene = $gene_ranges{$line2[0]}{'count'}[@{$gene_ranges{$line2[0]}{'count'}} - 1];
							$overlap_specific = $gene_ranges{$line2[0]}{$name[@name - 2]}[@{$gene_ranges{$line2[0]}{$name[@name - 2]}} - 1];
						}
						#overall gene basepairs:
						$stats{$line2[0]}{$_}{'count'} += in_bin_count($line2[3], $line2[4], $stats{$line2[0]}{$_}{'start'}, $stats{$line2[0]}{$_}{'end'},  $overlap_gene, \@{$gene_ranges{$line2[0]}{'count'}});
						#Store the basepairs occupied for that specific gene type:
						$stats{$line2[0]}{$_}{$name[@name - 2]} += in_bin_count($line2[3], $line2[4], $stats{$line2[0]}{$_}{'start'}, $stats{$line2[0]}{$_}{'end'}, $overlap_specific, \@{$gene_ranges{$line2[0]}{$name[@name - 2]}});
						#Store the name of the gene type:
						$gene_types{$name[@name - 2]} = 1;
						$switch++;
					}
				}
			}
		}
	}
}
close(IN);

open(my $merge, '>', "./merged.bed");
foreach (@chromosomes) {
	for(my $z = 0; $z < @{$gene_ranges{$_}{'count'}} - 1; $z += 2) {
		print $merge "$_\t$gene_ranges{$_}{'count'}[$z]\t$gene_ranges{$_}{'count'}[$z + 1]\n";
	}
}
close $merge;

my @gene_types = keys %gene_types;
@gene_types = sort { $a cmp $b } @gene_types;
print "Calculating Densities...\n";
##################################
### Calculate the gene density ###
##################################
my $bin;
foreach (keys %stats) {
	my $chr = $_;
	foreach (keys $stats{$chr}) {
		$bin = $_;
		if (!defined($stats{$chr}{$bin}{'count'})) {
			$stats{$chr}{$bin}{'count'} = 0;
		}
		$stats{$chr}{$bin}{'density'} = $stats{$chr}{$bin}{'count'} / ($stats{$chr}{$bin}{'end'} - $stats{$chr}{$bin}{'start'} + 1);
		foreach (@gene_types) {
			if (defined($stats{$chr}{$bin}{$_})) {
				$stats{$chr}{$bin}{$_} /= ($stats{$chr}{$bin}{'end'} - $stats{$chr}{$bin}{'start'} + 1);
			} else {
				$stats{$chr}{$bin}{$_} = 0;
			}
		}
	}
}
unshift @gene_types, "Overall_gene_density";
print "Outputting data summary...\n";
##################################################
### Read in the data summary file and store it ###
##################################################
my $i = 0;
my @header;
my %max_bin;
my $last_bin = 1;
open(DATAFILE, '<', "./data.summary.txt");
while(<DATAFILE>) {
	chomp;
	if ($_ =~ m/Chromosome/) {
		@header = split(/\t/, $_);
	} else	{
		my @line3 = split('\t', $_);
		unless (suffix($line3[0]) == 0) {
			$max_bin{$last_bin} = suffix($line3[0]);
		}
		if (eof) {
			$max_bin{prefix($line3[0])} = suffix($line3[0]);
		}
		$data_summary[$i] = \@line3;
		$last_bin = prefix($line3[0]);
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
my $chr_count = (@data_summary + 0);
my $line;
my $current;
$switch = 1;
open(my $fh, '>', "./data.summary.txt");
print $fh $header . "\n";
$last_bin = -1;
for ($i = 0; $i < $chr_count; $i++) {
	$base_chr = prefix($data_summary[$i][0]);
	$current = suffix($data_summary[$i][0]);
	if ($current < $last_bin) {
		$last_bin = -1;
	}
	if ($current != $last_bin + 1) {
		$switch = 1;
		$last_bin++;
		while ($switch == 1 && $last_bin < $max_bin{prefix($data_summary[$i][0])}) {
			$bin = $base_chr . "_" . $last_bin;
			$line = "$stats{$base_chr}{$bin}{'density'}\t";
			for (my $x = 0; $x < @gene_types + 0; $x++) {
				if ($x != @gene_types - 1) {
					$line .= "$stats{$base_chr}{$bin}{$gene_types[$x]}\t";
				} else {
					$line .= "$stats{$base_chr}{$bin}{$gene_types[$x]}\n";
				}
			}
			print $fh "$bin\t0\t0\t0\t0\t0\t0\t$line";
			$last_bin++;
			if ($last_bin == $current) {
				$switch = 0;
			}
		}
	}
	push @{$data_summary[$i]}, $stats{$base_chr}{$data_summary[$i][0]}{'density'};
	foreach(@gene_types) {
		push @{$data_summary[$i]}, $stats{$base_chr}{$data_summary[$i][0]}{$_};
	}
	$line = join("\t", @{$data_summary[$i]});
	print $fh $line . "\n";
	$last_bin = suffix($data_summary[$i][0]);
}
close $fh;
print "Done!\n";

#######################################
### Subroutine to return the suffix ###
#######################################
sub suffix {
        my $word = shift;
        $word =~ s/[0-9A-Z]+_([0-9]+)/$1/;
        return ($word);
}

#######################################
### Subroutine to return the prefix ###
#######################################
sub prefix {
	my $word = shift;
	$word =~ s/([0-9A-Z]+)_[0-9]+/$1/;
	return ($word);
}

#####################################################################################
### Subroutine to calculate the number of bp for the gene that fall in the bin    ###
###      (Gene overlaps within the same category are not double counted, and      ###
###	  multiple overlaps are not multiply subtracted, as the overlapping       ###
###	  regions become merged into a single range for later comparisons)        ###
#####################################################################################
sub in_bin_count {
	#Define the boundary variables
	my $Gstart = shift;
	my $Gend = shift;
	my $Bstart = shift;
	my $Bend = shift;
	my $last_range_end = shift;
	my $gene_ranges = $_[0];
	my $overlapping = 0;
	my @coordinates;

	if ($last_range_end > 0 && defined($gene_ranges->[@$gene_ranges - 1]) && $gene_ranges->[@$gene_ranges - 2] != $Gstart ) {
		$gene_ranges->[@$gene_ranges - 1] = $last_range_end;
	}
	if (defined($gene_ranges->[@$gene_ranges - 1]) && $gene_ranges->[@$gene_ranges - 2] == $Gstart && $gene_ranges->[@$gene_ranges - 1] == $Gend) {
		pop @$gene_ranges;
		pop @$gene_ranges;
	}
	#Calculate the in-bin gene range in the case that none of the prior ranges intersect, tested below
	@coordinates = ($Gstart, $Gend, $Bstart, $Bend);
	@coordinates = sort {$a <=> $b} @coordinates;
	$overlapping = $coordinates[2] - $coordinates[1] + 1;

	#Crank through the ranges and see if there's an intersect already
	for (my $x = 0; $x < @$gene_ranges - 1; $x += 2) {
		#if this prior gene range falls within the bin of interest
		unless ($gene_ranges->[$x + 1] < $Bstart || $gene_ranges->[$x] > $Bend) {
			#And if it intersects with our current gene range
			unless ($gene_ranges->[$x + 1] < $Gstart || $gene_ranges->[$x] > $Gend) {
				@coordinates = ($Bstart, $gene_ranges->[$x], $Gstart, $gene_ranges->[$x + 1], $Gend, $Bend);
				@coordinates = sort {$a <=> $b} @coordinates;
				#if the end of the prior genic range ends before the end of the current gene ends
				if ($gene_ranges->[$x + 1] < $Gend && $gene_ranges->[$x + 1] < $Bend) {
					$overlapping = $coordinates[4] - $coordinates[3] + 1;
				#in the case for which the past genic range completely covers the current gene or extends past the bin end
				} else {
					$overlapping = 0;
				}
			}
		}
	}
	#Store the new gene in the prior
	if (defined($gene_ranges->[@$gene_ranges - 1]) && $Gstart <= $gene_ranges->[@$gene_ranges - 1] + 1 && $Gend >= $gene_ranges->[@$gene_ranges - 1]) {
		pop @$gene_ranges;
		push @$gene_ranges, $Gend;
	} elsif (!defined($gene_ranges->[@$gene_ranges - 1]) || $Gstart > $gene_ranges->[@$gene_ranges - 1] + 1) {
		push @$gene_ranges, $Gstart, $Gend;
	}
	return $overlapping;
}
