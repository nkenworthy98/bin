#!/usr/bin/perl
# mpc search play
use strict;
use warnings;
use IPC::Open2;

my $music_dir = "$ENV{'HOME'}/.Music";

my @songs = grep { ! /\.git/ } `mpc listall`;
my $dmenu_str = join('', @songs);
my @selections = send_to_dmenu($dmenu_str);

if (@selections) {
 system("mpc clear");
 system("mpc", "add", @selections);
 system("mpc play");
}

sub send_to_dmenu {
  my ($string) = @_;

  my @dmenu_selections = ();
  my $pid = open2(my $child_out, my $child_in, 'dmenu -p "Song(s)?" -l 5 -i');
  print $child_in $string;
  close($child_in);
  @dmenu_selections = <$child_out>;
  chomp(@dmenu_selections);
  close($child_out);

  return @dmenu_selections;
}
