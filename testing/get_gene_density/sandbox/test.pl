#!/usr/bin/perl -w
use strict;
use File::Basename;
use Data::Dumper;

my %test;
my @test = ("N","Y","C");
@{$test{1}} = ("1_2", "1_3", "1_6", "1_7", "5_10");
@{$test{2}} = ("X", "Y");


my $testy = pop @test;

print Dumper(\@test);




#my $last = "A" ;
#my $current;
#my $scrap;
#foreach(@test) {
#	($scrap = $_ ) =~ s/\d_(\d+)/$1/;
#	unless ($last eq "A") {
#		$current = $_;
#		if (suffix($last) != suffix($current) - 1) {
#			print "Last is $last and this one is $current\n";
#		}
#	}
#	$last = $_;
#}

#my $infile = $ARGV[0];
#open (IN, '<', $infile);
#while(<IN>) {
#	if (eof) {
#		print "It's over!!!!";
#	}
#}


#foreach (keys %test) {
#	test_sub(\@{$test{$_}});
#}
#test_sub(\@test);
#print Dumper(%test);


#test_sub(\@{$test{3}});
#print Dumper(%test);




sub test_sub {
	my $array_ref = $_[0];
	print @$array_ref + 0 . "\n";
	push @$array_ref, "A", "B";
}

sub suffix {
	my $word = shift;
	$word =~ s/\d+_(\d+)/$1/;
	return ($word);
}

