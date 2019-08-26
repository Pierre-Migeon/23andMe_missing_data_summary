#!/usr/bin/perl -w
use strict;
use POSIX;
use Data::Dumper;

# To do:
# think about how everything fits together in terms of the formula while($start < $end) to make sure you're not truncating early or something
if ($ARGV[0] eq "-h") {
	print "
#######################################################################################
#        BED_FILE_BINNER.PL by Pierre Migeon					      #
#										      #
#  Description: Reads in a BED file and bins it accoring the input bin size. 	      #
#    Smaller bins at the end of the chromosome range are backwards expanded to        #
#    create equal sized bins, and size of the overlap is recorded for the purpose     #
#    of optimization of bin size. Binning range is shifted downstream to minimize     #
#    overlap. Use perl bed_file_binner.pl -h to print this message.		      #
#										      #
#  Usage: perl bed_file_binner.pl [bin size in basepairs]			      #
#										      #
#######################################################################################

";
exit;
}
#Variable Declarations:
#######################
my $bin_size = $ARGV[0];
my $start;
my $end;
my %newranges;
my @chromosomes;
#######################
#Read in the chromosome lengths file
####################################
open (T_LEN, '<', './maxrange_37.p10.txt');
while (<T_LEN>) {
	unless ($_ =~ m/^#/) {
		chomp;
		my @line = split(/\t/, $_);
		push @chromosomes, $line[0];
		#Define the start and end of the assayed range
                $start = 0;
                $end = $line[1];
                bin_chr ($start, $end, $line[0], \%newranges);
	}
}
close (T_LEN);

######################################
#open out range file and print header#
######################################
open( my $fh, '>', "./ranges.bed" );
print $fh "#Chromosome\tstart\tend\n";

#Open overlaps file for writing and print header
################################################
#open (my $fh2, '>>', "./overlaps.txt");
#if ( -s './overlaps.txt' == 0) {
#	print $fh2 "#Chromsome\tbin_size\toverlap\tscaled_overlap\taverage_overlap\taverage_scaled_overlap\n";
#}

#Print out the bins with their start and end coordinates as well as overlap when appropriate
#my $i = 0;
my $x;
foreach (@chromosomes) {
	$x = 0;
	while (defined(${$newranges{$_}}[$x])) {
		print $fh $_ . "_" . ${$newranges{$_}}[$x] . "\t" . ${$newranges{$_}}[$x + 1] . "\t" . ${$newranges{$_}}[$x + 2] . "\n";
#		if ($x == 0) {
#			print $fh2 "$_\t$bin_size\t${$newranges{'overlap'}}[$i]\t". (${$newranges{'overlap'}}[$i] / $bin_size ) . "\t$av_overlap\t" . ( $av_overlap / $bin_size ) . "\n";
#			$i++;
#		}
		$x += 3;
	}
}
close( $fh );
#close( $fh2 );

############################################################################
# subroutine to bin the chromosomes according to start and end coordinates #
############################################################################
sub bin_chr {
	my $start = shift;
	my $end = shift;
	my $chr = shift;
	my $newranges = shift;
	my $i = 0;

	while ($start < $end) {
		push @{$newranges{$chr}}, $i, $start;
		if ( $start + $bin_size > $end ) {
			push @{$newranges{$chr}}, $end;
			$start = $end;
		} else {
			$start += $bin_size;
			push @{$newranges{$chr}}, $start;
			$i++;
		}
	}
}


############################################################################################################
#Deprecated Subroutine Cemetery (THE DSC)
#(i.e., none of these subroutines are any longer in play, 
# but are memorialized here nonetheless)
###########################################################################
# subroutine to shift the bin range to cover the assayed range completely #
###########################################################################
sub adjust_boundries {
	#declare variables and do some calculations:
	my $start = shift;
	my $end = shift;
	my $bin_size = shift;
	my $chr_end = shift;
	my $range = $end - $start;
	my $bins_possible = floor($range / $bin_size);
	my $margin = $range - ($bins_possible * $bin_size);

	#calculate the range required to complete the last truncated bin
	$start = ($start - ceil ($margin / 2) > 0) ? $start - ceil ($margin / 2) : 0;
	$end = ($bins_possible == ($range / $bin_size)) ? (($start + $bin_size * $bins_possible <= $chr_end) ? $start + $bin_size * $bins_possible : $chr_end) : (($start + $bin_size * ++$bins_possible <= $chr_end) ? $start + $bin_size * ++$bins_possible : $chr_end);
	return ($start, $end);
}

##########################################################
# subroutine to filter out non-numeric for input to sort #
##########################################################
sub only_num {
	my @keys = @_;
	my $i = 0;
	foreach (@keys) {
		if ($_ =~ m/[A-Za-z]/) {
			splice @keys, $i, 1;
		}
		$i++;
	}
	return (@keys);
}
#####################################################################################
# Subroutine to calculate the overlap between the second to last and the last bins. #
#####################################################################################
sub overlap {
	my @array = @_;
	my $overlap = 0;
	my $x = 0;
	while (defined($array[$x])) {
		$x += 3;
	}
	$x -= 3;
	if ($array[$x - 1] != $array[$x + 1]) {
		$overlap = $array[$x - 1] - $array[$x + 1]
	}
	return $overlap;
}
######################################################################
# Subroutine to calculate the average overlap for the entire genome. #
######################################################################
sub average_overlap {
	my %hash = @_;
	my $sum = 0;
	my $chr_count = 0;
	my $average = 0;
	foreach (@{$hash{'overlap'}}) {
		$sum += $_;
		$chr_count++;
	}
	$average = $sum / $chr_count;
	return ( $average );
}
