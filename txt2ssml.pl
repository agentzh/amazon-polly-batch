#!/usr/bin/env perl

use v5.10.1;
use bytes;
use strict;
use warnings;

use Getopt::Std;

my %opts;
getopts("s:", \%opts) or die "Usage: $0 [-s SPEED] TXT-FILE\n";

my $speed = $opts{speed} // 'slow';

my @chunks;
my $chunk = qq{<speak><prosody rate="$speed">};
my $size = 0;
my $paragraphs = 0;
my $init_tags = qq{<speak><prosody rate="$speed"><break time="500ms"/>};
my $closing_tags = '</prosody></speak>';

while (<>) {
    next if /^\s*$/;

    chomp;

    if (/^[A-Z][^.,!?]+[a-z]$/) {
        my $len = bytes::length $_;
        if ($size + $len > 1500) {
            $chunk .= $closing_tags;
            push @chunks, $chunk;
            $chunk = $init_tags;
            $size = 0;
        }

        if ($len <= 50) {
            #warn "size: $size, len: $len";

            s/&/&amp;/g;
            s/</&lt;/g;
            s/>/&gt;/g;
            $chunk .= qq{<break time="500ms"/><emphasis>$_</emphasis><break time="500ms"/>};
            $size += $len;
            $paragraphs++;
            next;
        }
    }

    # a paragraph

    s/^\s+|\s+$//g;

    $paragraphs++;

    my $first = 1;
    while (/(.*?[.?;:]['")]*)/gc) {
        my $sentence = $1;
        #warn $sentence;
        my $len = bytes::length $sentence;

        #warn "size: $size, len: $len";

        if ($size + $len > 1500) {
            $chunk .= $closing_tags;
            push @chunks, $chunk;
            $chunk = $init_tags;
            $size = 0;
        }

        if ($first) {
            if ($paragraphs > 1) {
                $chunk .= '<break time="500ms"/>';
            }
            undef $first;
        }

        $sentence =~ s/\&/\&amp;/g;
        $sentence =~ s/</\&lt;/g;
        $sentence =~ s/>/\&gt;/g;
        #$sentence =~ s{N`([A-Za-z][^`]*?[A-Za-z])`}{<emphasis level="strong">$1</emphasis>}smg;

        $sentence =~ s{(?<!the) (["'])(.*?)\1}{
            my $mark = $1;
            my $v = $2;
            if ($v =~ /^\w+$/) {
                qq! <emphasis>$v</emphasis>!
            } else {
                qq! <break time="250ms"/>$mark$v$mark!
            }
        }esmg;

        $sentence =~ s{\bcrosslegged\b}{<phoneme alphabet="x-sampa" ph="kr\\OslEgd">crosslegged</phoneme>}gsm;
        $sentence =~ s{\bKuru\b}{<phoneme alphabet="x-sampa" ph="ku%r\\u">Kuru</phoneme>}gsm;
        $sentence =~ s{\bWill\b}{<phoneme alphabet="x-sampa" ph="%wil">Will</phoneme>}gsm;

        if ($len <= 1500) {
            $chunk .= $sentence;
            $size += $len;

        } else {
            die "$.: sentence too long: $sentence";
        }
    }

    if (pos $_ < bytes::length $_) {
        die "$.: unfinished sentence: ", substr $_, pos $_;
    }
}

if ($chunk) {
    $chunk .= $closing_tags;
    push @chunks, $chunk;
}

for my $chunk (@chunks) {
    $chunk =~ s/> />/g;
    $chunk =~ s{<break time="\d+m?s"/><break time="(\d+m?s)"/>}{<break time="$1"/>}gs;
    #warn "!!", bytes::length $chunk;
}

print join "\n", @chunks;
