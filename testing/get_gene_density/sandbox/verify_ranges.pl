#!/usr/bin/perl -w
use strict;

my $snps = $ARGV[0];
my %chr;
my @chr_cache;

open(IN, '<', $snps);
while(<IN>)
{
	unless ($_ =~ m/^#/)
	{
		my @line = split('\t', $_);
		if(!defined($chr{$line[1]})) { $chr{$line[1]}[0] = $line[2]; }
		if (defined($chr_cache[0]) && $line[1] ne $chr_cache[0]) { $chr{$chr_cache[0]}[1] = $chr_cache[1]; }
		if (eof) { $chr{$chr_cache[0]}[1] = $line[2]; }
		$chr_cache[0] = $line[1];
		$chr_cache[1] = $line[2];
	}
}
close(IN);

print $chr{'1'}[0] . "\t" . $chr{'1'}[1] . "\n";
print $chr{'MT'}[0] . "\t" . $chr{'MT'}[1] . "\n";

foreach (sort keys %chr)
{
	print $_ . "\t\t" . ($chr{$_}[1] - $chr{$_}[0]) . "\n";
}
