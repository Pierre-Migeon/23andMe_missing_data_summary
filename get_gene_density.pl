#!/usr/bin/perl -w
use strict;
use Data::Dumper;

#Description: Reads in a GTF format file and a list of ranges and outputs gene density statistics for each of those ranges. Runs as a part of my 23andme analysis pipeline. Requires the presence of a human genome GFT file, a bedfile of the ranges from the 23andme analaysis, and a data summary file that is subsequently appended to by the running of this script.

my %stats;
my @data_summary;

###########################
### Read in the Bedfile ###
###########################
open(RANGES, '<', "./ranges.bed");
while(<RANGES>)
{
	unless ($_ =~ "^#") {
		my @line1 = split('\t', $_);
		$stats{$line1[0]}{'start'} = $line1[1];
		$stats{$line1[0]}{'end'} = $line1[2];
	}
}
close(RANGES);

############################
### Read in the GFT file ###
############################
open(IN, '<', "./Homo_sapiens.GRCh38.97.gtf");
while(<IN>)
{
	unless ($_ =~ '^#') {
	my @line2 = split('\t', $_);
	#if it's a gene:
	if ($line2[2] =~ m/gene/) {
		#If it's one of the chromosomes that we are looking at (exludes rando scaffolds for instance):
		if (defined($stats{$line2[0]})) {
			#If it fits within the assayed range:
			if ($line2[3] >= $stats{$line2[0]}{'start'} && $line2[4] <= $stats{$line2[0]}{'end'}) {
				$stats{$line2[0]}{'count'}++;
				if ($_ =~ m/IG_C_gene/) {
					$stats{$line2[0]}{IG_C_gene}++;
				}
				if ($_ =~ m/IG_C_pseudogene/) {
					$stats{$line2[0]}{IG_C_pseudogene}++;
				}
				if ($_ =~ m/IG_D_gene/) {
					$stats{$line2[0]}{IG_D_gene}++;
				}
				if ($_ =~ m/IG_J_gene/) {
					$stats{$line2[0]}{IG_J_gene}++;
				}
				if ($_ =~ m/IG_J_pseudogene/) {
					$stats{$line2[0]}{IG_J_pseudogene}++;
				}
				if ($_ =~ m/IG_V_gene/) {
					$stats{$line2[0]}{IG_V_gene}++;
				}
				if ($_ =~ m/IG_V_pseudogene/) {
					$stats{$line2[0]}{IG_V_pseudogene}++;
				}
				if ($_ =~ m/IG_pseudogene/) {
					$stats{$line2[0]}{IG_pseudogene}++;
				}
				if ($_ =~ m/Mt_rRNA/) {
					$stats{$line2[0]}{Mt_rRNA}++;
				}
				if ($_ =~ m/Mt_tRNA/) {
					$stats{$line2[0]}{Mt_tRNA}++;
				}
				if ($_ =~ m/TEC/) {
					$stats{$line2[0]}{TEC}++;
				}
				if ($_ =~ m/TR_C_gene/) {
					$stats{$line2[0]}{TR_C_gene}++;
				}
				if ($_ =~ m/TR_D_gene/) {
					$stats{$line2[0]}{TR_D_gene}++;
				}
				if ($_ =~ m/TR_J_gene/) {
					$stats{$line2[0]}{TR_J_gene}++;
				}
				if ($_ =~ m/TR_J_pseudogene/) {
					$stats{$line2[0]}{TR_J_pseudogene}++;
				}
				if ($_ =~ m/TR_V_gene/) {
					$stats{$line2[0]}{TR_V_gene}++;
				}
				if ($_ =~ m/TR_V_pseudogene/) {
					$stats{$line2[0]}{TR_V_pseudogene}++;
				}
				if ($_ =~ m/lncRNA/) {
					$stats{$line2[0]}{lncRNA}++;
				}
				if ($_ =~ m/miRNA/) {
					$stats{$line2[0]}{miRNA}++;
				}
				if ($_ =~ m/misc_RNA/) {
					$stats{$line2[0]}{misc_RNA}++;
				}
				if ($_ =~ m/polymorphic_pseudogene/) {
					$stats{$line2[0]}{polymorphic_pseudogene}++;
				}
				if ($_ =~ m/processed_pseudogene/) {
					$stats{$line2[0]}{processed_pseudogene}++;
				}
				if ($_ =~ m/protein_coding/) {
					$stats{$line2[0]}{protein_coding}++;
				}
				if ($_ =~ m/pseudogene/) {
					$stats{$line2[0]}{pseudogene}++;
				}
				if ($_ =~ m/rRNA/) {
					$stats{$line2[0]}{rRNA}++;
				}
				if ($_ =~ m/rRNA_pseudogene/) {
					$stats{$line2[0]}{rRNA_pseudogene}++;
				}
				if ($_ =~ m/ribozyme/) {
					$stats{$line2[0]}{ribozyme}++;
				}
				if ($_ =~ m/sRNA/) {
					$stats{$line2[0]}{sRNA}++;
				}
				if ($_ =~ m/scRNA/) {
					$stats{$line2[0]}{scRNA}++;
				}
				if ($_ =~ m/scaRNA/) {
					$stats{$line2[0]}{scaRNA}++;
				}
				if ($_ =~ m/snRNA/) {
					$stats{$line2[0]}{snRNA}++;
				}
				if ($_ =~ m/snoRNA/) {
					$stats{$line2[0]}{snoRNA}++;
				}
				if ($_ =~ m/transcribed_processed_pseudogene/) {
					$stats{$line2[0]}{transcribed_processed_pseudogene}++;
				}
				if ($_ =~ m/transcribed_unitary_pseudogene/) {
					$stats{$line2[0]}{transcribed_unitary_pseudogene}++;
				}
				if ($_ =~ m/transcribed_unprocessed_pseudogene/) {
					$stats{$line2[0]}{transcribed_unprocessed_pseudogene}++;
				}
				if ($_ =~ m/translated_processed_pseudogene/) {
					$stats{$line2[0]}{translated_processed_pseudogene}++;
				}
				if ($_ =~ m/translated_unprocessed_pseudogene/) {
					$stats{$line2[0]}{translated_unprocessed_pseudogene}++;
				}
				if ($_ =~ m/unitary_pseudogene/) {
					$stats{$line2[0]}{unitary_pseudogene}++;
				}
				if ($_ =~ m/unprocessed_pseudogene/) {
					$stats{$line2[0]}{unprocessed_pseudogene}++;
				}
				if ($_ =~ m/vaultRNA/) {
					$stats{$line2[0]}{vaultRNA}++;
				}
			}
		}
	}
	}
}
close(IN);
##################################
### Calculate the gene density ###
##################################
foreach(keys %stats) {
	$stats{$_}{'density'} = $stats{$_}{'count'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
	$stats{$_}{'IG_C_gene_density'} = $stats{$_}{'IG_C_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'IG_C_pseudogene_density'} = $stats{$_}{'IG_C_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'IG_D_gene_density'} = $stats{$_}{'IG_D_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'IG_J_gene_density'} = $stats{$_}{'IG_J_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'IG_J_pseudogene_density'} = $stats{$_}{'IG_J_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'IG_V_gene_density'} = $stats{$_}{'IG_V_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'IG_V_pseudogene_density'} = $stats{$_}{'IG_V_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'IG_pseudogene_density'} = $stats{$_}{'IG_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'Mt_rRNA_density'} = $stats{$_}{'Mt_rRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'Mt_tRNA_density'} = $stats{$_}{'Mt_tRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'TEC_density'} = $stats{$_}{'TEC'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'TR_C_gene_density'} = $stats{$_}{'TR_C_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'TR_D_gene_density'} = $stats{$_}{'TR_D_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'TR_J_gene_density'} = $stats{$_}{'TR_J_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'TR_J_pseudogene_density'} = $stats{$_}{'TR_J_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'TR_V_gene_density'} = $stats{$_}{'TR_V_gene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'TR_V_pseudogene_density'} = $stats{$_}{'TR_V_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'lncRNA_density'} = $stats{$_}{'lncRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'miRNA_density'} = $stats{$_}{'miRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'misc_RNA_density'} = $stats{$_}{'misc_RNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'polymorphic_pseudogene_density'} = $stats{$_}{'polymorphic_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'processed_pseudogene_density'} = $stats{$_}{'processed_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'protein_coding_density'} = $stats{$_}{'protein_coding'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'pseudogene_density'} = $stats{$_}{'pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'rRNA_density'} = $stats{$_}{'rRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'rRNA_pseudogene_density'} = $stats{$_}{'rRNA_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'ribozyme_density'} = $stats{$_}{'ribozyme'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'sRNA_density'} = $stats{$_}{'sRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'scRNA_density'} = $stats{$_}{'scRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'scaRNA_density'} = $stats{$_}{'scaRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'snRNA_density'} = $stats{$_}{'snRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'snoRNA_density'} = $stats{$_}{'snoRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'transcribed_processed_pseudogene_density'} = $stats{$_}{'transcribed_processed_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'transcribed_unitary_pseudogene_density'} = $stats{$_}{'transcribed_unitary_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'transcribed_unprocessed_pseudogene_density'} = $stats{$_}{'transcribed_unprocessed_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'translated_processed_pseudogene_density'} = $stats{$_}{'translated_processed_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'translated_unprocessed_pseudogene_density'} = $stats{$_}{'translated_unprocessed_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'unitary_pseudogene_density'} = $stats{$_}{'unitary_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'unprocessed_pseudogene_density'} = $stats{$_}{'unprocessed_pseudogene'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
        $stats{$_}{'vaultRNA_density'} = $stats{$_}{'vaultRNA'} / ($stats{$_}{'end'} - $stats{$_}{'start'});
	}
##################################################
### Read in the data summary file and store it ###
##################################################
my $i = 0;
open(DATAFILE, '<', "./data.summary.txt");
while(<DATAFILE>) {
	my @line3 = split('\t', $_);
	unless ($line3[0] =~ m/Chr/ ) {
		$data_summary[$i] = \@line3; 
		$i++;
	}
}
close(DATAFILE);
##################################################################
### Output the data summary with the added gene density column ###
##################################################################
my $chr_count = (scalar keys %stats);
my $line;
open(my $fh, '>', "./data.summary.txt");
print $fh "Chromosome\tRange\tgene_density\tP_gene_density\tSNPs\tSNP_density\tMissing\t%_missing\tMissing_density\n";
for( $i = 0; $i < $chr_count; $i++ ) {
	splice(@{$data_summary[$i]}, 2, 0, $stats{$data_summary[$i][0]}{'Prot_coding_density'});
	splice(@{$data_summary[$i]}, 2, 0, $stats{$data_summary[$i][0]}{'density'});
	$line = join("\t", @{$data_summary[$i]});
	print $fh $line;
}
print Dumper(@data_summary);
close $fh;
