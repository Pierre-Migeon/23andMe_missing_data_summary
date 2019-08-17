#!/bin/bash

#If you're at the beginning of the check, then clear whatever was in the file before and start a fresh summary file 

begin="Overall_gene_density"
if [ "$1" == "$begin" ]
then
	echo -n  > correctness_summary.txt
fi
#Generate the gene bedfile:
perl generate_gene_ranges.pl $1 > gene.bed
#merge the ranges:
bedtools merge -d 1 -i gene.bed > merged.bed
#calculate the density:
perl density_per_bin.pl ./merged.bed ../../ranges.bed > density.txt
#Compare to your calculations:
perl compare_to_data_summary.pl $1 >> correctness_summary.txt
