#!/usr/bin/perl
# mpc search play
use strict;
use warnings;
use IPC::Open2;
use Getopt::Long qw(GetOptions HelpMessage);

# CLI Flags/Variables
my $append_flag = 0;
my $insert_flag = 0;

GetOptions(
  'append|a' => sub { $append_flag = 1; },
  'help|h' => sub { HelpMessage(0) },
  'insert|i' => sub { $insert_flag = 1; },
) or HelpMessage(1);

my $prompt_str;
if ($append_flag) {
  $prompt_str = "Append Song(s)";
}
elsif ($insert_flag) {
  $prompt_str = "Insert Song(s)";
}
else {
  $prompt_str = "Song(s)";
}

my @songs = grep { ! /\.git/ } `mpc listall`;
my $dmenu_songs_str = join('', @songs);
my $selections_ref = pipe_to_dmenu($dmenu_songs_str, $prompt_str);

if (@{$selections_ref}) {
  system("mpc clear") unless ($append_flag || $insert_flag);

  system("mpc", "add", @{$selections_ref}) unless $insert_flag;
  system("mpc", "insert", @{$selections_ref}) if $insert_flag;

  system("mpc play");
}

sub pipe_to_dmenu {
  my ($songs_str, $prompt_str) = @_;

  my @dmenu_selections = ();
  my $pid = open2(my $reader, my $writer, "dmenu -p '$prompt_str' -l 5 -i");
  print $writer $songs_str;
  close($writer);
  @dmenu_selections = <$reader>;
  chomp(@dmenu_selections);
  close($reader);

  return \@dmenu_selections;
}

=head1 NAME

msp.pl - mpc search play

=head1 SYNOPSIS

msp.pl [OPTION]

  -a, --append     Append selection(s) to current queue
  -h, --help       Print this help and exit
  -i, --insert     Insert selection(s) to current queue

For more detailed documentation, run C<perldoc msp.pl>

=cut
