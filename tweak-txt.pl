#!/usr/bin/env perl

use strict;
use warnings;

my $infile = shift or die "No input file specified.\n";

open my $in, $infile or die "Cannot open $infile for reading: $!";
my $s = do { local $/; <$in> };
close $in;

$s =~ s/\r\n[A-Z]+(?:\s+[A-Z]+)*\s+(?:\d+|[xXVvIil]+)$//gms;
$s =~ s/\r\n(?:\d+|[xXVvIil]+)\s+[A-Z]+(?:\s+[A-Z]+)*$//gms;
$s =~ s/\r\n(?:\d+|[xXVvIil]+)\s+[A-Z]\S+[A-Z](?:\s+[A-Z]\S+[A-Z])*$//gms;
$s =~ s/\r\n+Contents\n+\r.*?\r\n+(INTRODUCTION\n\n)/\r\n\n$1/ms;
$s =~ s/ ([a-z]+)(?:-|\x{c2}\x{ad}) +([a-z]+[ ,.;?!])/ $1$2/msg;
#$s =~ s/ technologi­ cal / technological /msg;
$s =~ s/\([^).\n]*?[a-z][^).\n]*?[a-z][^).\n]*?\)//msg;
print $s;
