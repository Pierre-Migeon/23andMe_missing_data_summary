#!/usr/bin/perl
use strict;
use Math::Round;

my $snps = $ARGV[0];
my $missing_count = 0;
my $total_count = 0;
my %missing_by_chr;

open(IN, '<', $snps);
while(<IN>)
{
	unless($_ =~ '^#')
	{
		my @line = split('\t', $_);
		$missing_by_chr{$line[1]}[0]++;
		if ($line[3] =~ m/--/)
		{
			$missing_by_chr{$line[1]}[1]++;
			$missing_count++;
		}
		$total_count++;
	}
}
print "#####################################################################################\n";
print "There were " . $missing_count . " homozygous missing data sites, for a total of " . nearest(.01, $missing_count / $total_count * 100) . "% missing data.\n\n";
print "\t\t\t\t\tchr\t     missing\n";
print "\t\t\t\t\t--------------------\n";
foreach(sort { $a <=> $b } keys(%missing_by_chr))
{
	unless($_ =~ m/[A-Z]/)
	{
		print "\t\t\t\t\t " . $_ . "\t\t" . $missing_by_chr{$_}[1] . "\n";
	}
}
foreach (sort { $a cmp $b } keys(%missing_by_chr))
{
	unless($_ =~ m/[1-9]/)
	{       
                print "\t\t\t\t\t " . $_ . "\t\t" . $missing_by_chr{$_}[1] . "\n";
        }
}
print "\t\t\t\t\t--------------------\n";
print "\t\t\t\t\ttotal\t\t" . $missing_count . "\n";
print "\n" . nearest(0.01, $missing_by_chr{'Y'}[1] / $missing_count * 100) . "% missing data located on the Y chromsome, w/ " . nearest(0.01, $missing_by_chr{'Y'}[1] / $missing_by_chr{'Y'}[0] * 100) . "% Y chromosome loci missing\n";
print "#####################################################################################\n"; 
