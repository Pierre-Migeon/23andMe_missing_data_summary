




open ( IN, '<', "./range.bed");
my @line = split("\t", readline IN);
close IN;
chomp $line[2];

open ( IN, '<', "/Users/pierre/bioinformatics/23andme/missing_data/update2/coordinate_convert/ref_ref_GRCh37.p10_top_level.gff3" );
while( <IN> ) {
	unless ( $_ =~ m/^#/ ) {
		my @line2 = split(/\t/, $_);
		if ( $line2[2] eq "gene" && $line2[0] eq prefix($line[0])) {
			if ($line2[4] > $line[1] && $line2[3] < $line[2]) {
				print $_;
			}
		}
	}
}

#######################################
### Subroutine to return the prefix ###
#######################################
sub prefix {
	my $word = shift;
	$word =~ s/([0-9A-Z]+)_[0-9]+/$1/;
	return ($word);
}
