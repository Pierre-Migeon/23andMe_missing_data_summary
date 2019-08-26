#!/usr/bin/perl -w
use strict;

#Description: this code writes code, so that I can copy and paste it into the get_gene_density script and use it to analyze and annotate my 23andme data.

my @types;
my $i = 0;

#Open file of list of gene types
open(TYPES, '<', "./gene_types.txt");
while(<TYPES>) {
	chomp;
	$types[$i++] = $_;
}

$i--;
for(0..$i) {
#	print '				if ($_ =~ m/' . $types[$_] . '/) {
#					$stats{$line2[0]}{' . $types[$_] . '}++;
#				}' . "\n";
print '        $stats{$_}{\'' . $types[$_] . '_density\'} = $stats{$_}{\'' . $types[$_] . '\'} / ($stats{$_}{\'end\'} - $stats{$_}{\'start\'});' . "\n";
}

