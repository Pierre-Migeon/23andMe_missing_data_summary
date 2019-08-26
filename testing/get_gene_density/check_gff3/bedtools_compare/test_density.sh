#!/bin/bash

#Description: Shell pipeline to calculate the gene density based on bedtools, and then compare this to the calculations that were done using my script. The annotation parameter is a holdover from the use of GTF file (couldn't find a GTF file for this genome version).
#Usage: bash test_density.sh gene_density

#If you're at the beginning of the check, then clear whatever was in the file before and start a fresh summary file 
begin="gene_density"
if [ "$1" == "$begin" ]
then
	echo -n  > correctness_summary.txt
fi
#Generate the gene bedfile:
perl generate_gene_ranges.pl $1 > gene.bed
#merge the ranges:
bedtools merge -i gene.bed > merged.bed
#calculate the density:
perl density_per_bin.pl ./merged.bed ./../../../../ranges.bed > density.txt
#Compare to your calculations:
perl compare_to_data_summary.pl $1 >> correctness_summary.txt
