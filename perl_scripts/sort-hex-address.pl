#!/usr/bin/perl
# Useful for sorting items and associated memory addresses that are in an org
# file
# Sorts lines by the hexadecimal address in them (picks the first hexadecimal
# in the line)
#
# One example showing lines that will produce the expected output:
#
#- First item - 0x18231987
#- Second item - 0x01
#- Third item - 0x0918239
#
# and returns
#
#- Second item - 0x01
#- Third item - 0x0918239
#- First item - 0x18231987
use strict;
use warnings;
use bigint qw(hex);

my @lines = <STDIN>;
chomp(@lines);

print
    map { $_->[0], "\n" }
    sort { $a->[1] <=> $b->[1] }
    map {
        my $hex;
        if (/(0x[0-9a-fA-F]+)/) {
            $hex = $1;
        }
        my $decimal_equiv = hex $hex;
        [$_, $decimal_equiv];
    }
    @lines;
