#!/usr/bin/perl
# List all unique fields/tags that are currently being used with git-annex
use strict;
use warnings;
use List::Util qw(uniq);

my @metadata_output = `git annex metadata`;
chomp(@metadata_output);

my @tags =
    uniq
    sort { $a cmp $b }
    grep { $_ ne "" }
    map {
        if (/tag=(.*?)$/) {
            "tag\t$1";
        }
        elsif (/^\s*(\S+)=/) {
            "field\t$1";
        }
    }
    @metadata_output;

print "$_\n" for @tags;
