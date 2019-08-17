#!/usr/bin/perl -w
use strict;



#for (1..100) {
#	`sleep 1`;
#	if ($_ % 2 == 0) {
#		print "H";
#	}
#	`sleep 1`;
#	if ($_ % 1 == 0) {
#		print "\033[2K\b";
#        }
#
#}


for (0..5) {
`sleep 1`;
if ($_ > 0) {
	print "\033[1A\033[4D";
	}
print ".";
`sleep 1`;
print ".";
`sleep 1`;
print ".\n";
`sleep 1`;
print "\033[1A";
print "   \n";
`sleep 1`;
}
