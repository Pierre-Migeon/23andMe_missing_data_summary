#!/usr/bin/perl -w
use strict;

#my $snps = $ARGV[0];
#my %hash;



open(DATAFILE, '<', "data.summary.txt");
while(<DATAFILE>)
{
	print $_;
}
close(DATAFILE);




#open(IN, '<', $snps);
#while(<IN>)
#{
#	my @line = split('\t', $_);
#}
#
#my %sum;
#for(1..5)
#{
#	print $_ . "\n";
#	$sum{'sum'} += $_;
#}

#print $sum{'sum'};


#print "The sum is $sum{'sum'} and ($sum{'sum'} * 100)";
