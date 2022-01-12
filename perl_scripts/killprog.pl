#!/usr/bin/perl
use strict;
use warnings;

my $program = $ARGV[0];

if (`pidof $program`) {
  `notify-send '$program' killed`;
  exec("killall $program");
}
