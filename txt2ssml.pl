#!/usr/bin/env perl

use v5.10.1;
use bytes;
use strict;
use warnings;

use Getopt::Std;

sub process_sentence ($$);

my %opts;
getopts("s:", \%opts) or die "Usage: $0 [-s SPEED] TXT-FILE\n";

my $speed = $opts{s} // 'slow';

my @chunks;
my $chunk = qq{<speak><prosody rate="$speed">};
my $size = 0;
my $paragraphs = 0;
my $init_tags = qq{<speak><prosody rate="$speed"><break time="250ms"/>};
my $closing_tags = '</prosody></speak>';

while (<>) {
    next if /^\s*$/;

    chomp;

    #warn "line: $_";

    if (/^[A-Z][^.,!?]+[A-Za-z]$/) {
        my $len = bytes::length $_;
        if ($size + $len > 1500) {
            $chunk .= $closing_tags;
            push @chunks, $chunk;
            $chunk = $init_tags;
            $size = 0;
        }

        if ($len <= 50) {
            #warn "size: $size, len: $len";
            #warn "found title: $_";

            s/&/&amp;/g;
            s/</&lt;/g;
            s/>/&gt;/g;
            $chunk .= qq{<break time="250ms"/>$_.<break time="250ms"/>};
            $size += $len;
            $paragraphs++;
            next;
        }
    }

    # a paragraph

    s/^\s+|\s+$//g;

    $paragraphs++;

    my $first = 1;
    while (/(.*?[.?!;:]+['")]*)(?:\s+|\z)/gcsm) {
        process_sentence($1, \$first);
    }

    if (!defined pos $_) {
        process_sentence($_, \$first);
        next;
    }

    if (pos $_ < bytes::length $_) {
        process_sentence(substr($_, pos $_), \$first);
    }
}

sub process_sentence ($$) {
    my ($sentence, $rfirst) = @_;

    #warn "found sentence: $sentence";
    my $len = bytes::length $sentence;

    #warn "size: $size, len: $len";

    if ($size + $len > 1500) {
        $chunk .= $closing_tags;
        push @chunks, $chunk;
        $chunk = $init_tags;
        $size = 0;
    }

    if ($$rfirst) {
        if ($paragraphs > 1) {
            $chunk .= '<break time="250ms"/>';
        }
        $$rfirst = 0;
    }

    $sentence =~ s/\&/\&amp;/g;
    $sentence =~ s/</\&lt;/g;
    $sentence =~ s/>/\&gt;/g;
    #$sentence =~ s{N`([A-Za-z][^`]*?[A-Za-z])`}{<emphasis level="strong">$1</emphasis>}smg;
    $sentence =~ s{VB`([A-Za-z][^`]*?[A-Za-z])`}{<w role="amazon:VB">$1</w>}smg;
    $sentence =~ s{VBD`([A-Za-z][^`]*?[A-Za-z])`}{<w role="amazon:VBD">$1</w>}smg;
    $sentence =~ s{N`([A-Za-z][^`]*?[A-Za-z])`}{<w role="amazon:SENSE_1">$1</w>}smg;

    $sentence =~ s{(?<=[,:"']) (["'])(.*?)\1}{
        my $mark = $1;
        my $v = $2;
        if ($v =~ /^\w+$/) {
            qq! <emphasis>$v</emphasis>!
        } else {
            qq! <break time="250ms"/>$mark$v$mark!
        }
    }esmg;

    #warn "sentence: [$sentence]";
    $sentence =~ s/([A-Za-z])_([A-Za-z\d])/$1 $2/g;
    $sentence =~ s!\bDIV\b! <phoneme alphabet="x-sampa" ph="&quot;di%aI%vi">DIV<\/phoneme> !gis;
    $sentence =~ s!\bMIME\b! <phoneme alphabet="x-sampa" ph="&quot;Em%aI%Em%i">MIME<\/phoneme> !gis;
    $sentence =~ s! / ! <phoneme alphabet="x-sampa" ph="&quot;sl{S">/<\/phoneme> !gis;
    $sentence =~ s{\bnginx\.conf\b}{nginx<phoneme alphabet="x-sampa" ph="&quot;dQt">.<\/phoneme>conf }gis;
    $sentence =~ s{\bInc\b}{<phoneme alphabet="x-sampa" ph="&quot;Ink">Inc<\/phoneme>}gis;
    $sentence =~ s{\bconf\b}{<phoneme alphabet="x-sampa" ph="&quot;kQnf">conf<\/phoneme>}gis;
    $sentence =~ s{\bvim\b}{<phoneme alphabet="x-sampa" ph="&quot;vi%aI%Em">vim<\/phoneme>}gis;
    $sentence =~ s{\`-s\`}{<phoneme alphabet="x-sampa" ph="%d\{S.&quot;Es">`-s`<\/phoneme>}gis;
    $sentence =~ s{\`-p\`}{<phoneme alphabet="x-sampa" ph="%d\{S.&quot;pi">`-p`<\/phoneme>}gis;
    $sentence =~ s{\`-t\`}{<phoneme alphabet="x-sampa" ph="%d\{S.&quot;ti">`-t`<\/phoneme>}gis;
    $sentence =~ s{\`-h\`}{<phoneme alphabet="x-sampa" ph="%d\{S.&quot;eItS">`-h`<\/phoneme>}gis;
    $sentence =~ s{\`-I\`}{<phoneme alphabet="x-sampa" ph="%d\{S.&quot;aI">`-h`<\/phoneme>}gis;
    $sentence =~ s{\`restydoc\`}{<phoneme alphabet="x-sampa" ph="%r\\EstI.&quot;dOk">`restydoc`<\/phoneme>}gis;
    $sentence =~ s{\bsudo\b}{<phoneme alphabet="x-sampa" ph="%sU&quot;dU">sudo<\/phoneme>}gis;
    $sentence =~ s{\bnginx\b}{<phoneme alphabet="x-sampa" ph="\%EndZ\@n&quot;Eks">nginx<\/phoneme>}gis;
    $sentence =~ s{\bcrosslegged\b}{<phoneme alphabet="x-sampa" ph="kr\\OslEgd">crosslegged</phoneme>}gsm;
    $sentence =~ s{\bKuru\b}{<phoneme alphabet="x-sampa" ph="ku%r\\u">Kuru</phoneme>}gsm;
    $sentence =~ s{\bWill\b}{<phoneme alphabet="x-sampa" ph="%wil">Will</phoneme>}gsm;
    $sentence =~ s{\b(?:IR|ir)\b}{<prosody rate="x-slow">I R</prosody>}gsm;
    $sentence =~ s{\b(?:ssa|SSA)\b}{<prosody rate="medium">S S A</prosody>}gsm;
    $sentence =~ s{\bconcentrated\b}{<phoneme alphabet="x-sampa" ph="%kAnsntSeItId">concentrated</phoneme>}gsm;
    #$sentence =~ s{((?:\b[a-zA-Z]+\s*)+)}{<lang xml:lang="en-US">$1</lang>}gsm;

    if ($len <= 1500) {
        $chunk .= " $sentence";
        $size += $len;

    } else {
        die "$.: sentence too long: $sentence";
    }
}

if ($chunk) {
    $chunk .= $closing_tags;
    push @chunks, $chunk;
}

for my $chunk (@chunks) {
    #$chunk =~ s/> />/g;
    $chunk =~ s{<break time="\d+m?s"/><break time="(\d+m?s)"/>}{<break time="$1"/>}gs;
    #warn "!!", bytes::length $chunk;
}

$chunks[-1] =~ s{(</speak>)}{<break time="250ms"/>$1};

print join "\n", @chunks;
