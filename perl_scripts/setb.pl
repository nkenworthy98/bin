#!/usr/bin/perl
use strict;
use warnings;

my $brightness = '';
if ($ARGV[0]) {
  $brightness = $ARGV[0];
}
else {
  $brightness = `printf '' | dmenu -p 'Brightness?'`;
}

`printf '%s\n' "$brightness" > /tmp/brightness`;

exec("light -S $brightness");
