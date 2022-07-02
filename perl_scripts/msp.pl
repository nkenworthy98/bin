#!/usr/bin/perl
# mpc search play
use strict;
use warnings;
use IPC::Open2;
use Getopt::Long qw(GetOptions HelpMessage);

my $music_dir = "$ENV{'HOME'}/.Music";

# CLI Flags/Variables
my $append_flag = 0;

GetOptions(
  'append|a' => \$append_flag,
  'help|h' => sub { HelpMessage(0) },
) or HelpMessage(1);

my @songs = grep { ! /\.git/ } `mpc listall`;
my $dmenu_str = join('', @songs);
my @selections = send_to_dmenu($dmenu_str);

if (@selections) {
 system("mpc clear") unless $append_flag;
 system("mpc", "add", @selections);
 system("mpc play") unless $append_flag;
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

=head1 NAME

msp.pl - mpc search play

=head1 SYNOPSIS

msp.pl [OPTION]

  -a, --append     Append selection(s) to current queue
  -h, --help       Print this help and exit

For more detailed documentation, run C<perldoc msp.pl>

=cut
