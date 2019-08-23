#!/bin/bash
#Updata data summary and ranges.bed for both synthetic_data directory and the trial_run directory
cd ../../../ && perl missing_data_ranged.pl ./SNP_binner/SNPs_binned.txt && cp ./data.summary.txt ./testing/get_gene_density/trial_run && cp ./ranges.bed ./testing/get_gene_density/trial_run && cp ./ranges.bed ./testing/get_gene_density/synthetic_data && cd ./testing/get_gene_density/synthetic_data
#Generate the GTF file
perl generate_GTF.pl 3
#Place a copy in the trial run directory
cp synthetic.Homo_sapiens.GRCh38.97.gtf ../trial_run/
#Update the gtf copy in the bedtools_compare directory
cp synthetic.Homo_sapiens.GRCh38.97.gtf ../bedtools_compare
#Get gene density:
cd ../trial_run/ && perl ./get_gene_density.pl && cd ../synthetic_data
#Compare:
perl compare_to_data_summary.pl Overall_gene_density
