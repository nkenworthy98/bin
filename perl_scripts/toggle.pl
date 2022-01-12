#!/usr/bin/perl
use strict;
use warnings;

my $program = $ARGV[0];

if (`pidof $program`) {
  `notify-send '$program' off`;
  system("killall $program");
}
else {
  `notify-send '$program' on`;
  system("$program");
}
