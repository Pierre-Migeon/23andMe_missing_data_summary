#!/usr/bin/perl -w
use strict;

open(IN, '<', "./test");
while(<IN>) {
	if ($_ !~ "word") {
		print $_;
	}
}



my $int = int(rand(50)) + 51;

print $int . "\n";
