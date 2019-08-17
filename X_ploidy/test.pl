#!/usr/bin/perl -w
use strict;



my @input;
$input[0] = "AA";
$input[1] = "A";
$input[2] = "I";
$input[3] = "II";
$input[4] = "DD";
$input[5] = "D";
$input[6] = "CC";
$input[7] = "C";
$input[8] = "TT";
$input[9] = "T";
$input[10] = "GG";
$input[11] = "G";

foreach(@input) {
	if ($_ =~ m/[ATCGID][ATCGID]/) {
		;
	} elsif ($_ =~ m/[ATCGID]/) {
		print "$_\n";
	}
}
