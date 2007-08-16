# $Id: zoomscan.pl,v 1.2 2007-08-16 16:21:08 mike Exp $
#
# This is the scanning counterpart to zoomscan.pl's searching
# perl -I../../blib/lib -I../../blib/arch zoomscan.pl <target> <scanQuery>

use strict;
use warnings;
use ZOOM;

if (@ARGV != 2) {
    print STDERR "Usage: $0 target scanQuery\n";
    print STDERR "	eg. $0 z3950.indexdata.dk/gils computer\n";
    exit 1;
}
my($host, $scanQuery) = @ARGV;

eval {
    my $conn = new ZOOM::Connection($host, 0);
    $conn->option(preferredRecordSyntax => "usmarc");
    ### Could use ZOOM::Query::CQL below, but that only work in SRU/W.
    my $ss = $conn->scan(new ZOOM::Query::PQF($scanQuery));
    my $n = $ss->size();
    for my $i (0..$n-1) {
	my($term, $occ) = $ss->term($i);
	print $i+1, ": $term";
	print " ($occ)" if defined $occ;
	print "\n";
    }
    
    $ss->destroy();
    $conn->destroy();
}; if ($@) {
    die "Non-ZOOM error: $@" if !$@->isa("ZOOM::Exception");
    print STDERR "ZOOM error $@\n";
    exit 1;
}
