#!/usr/bin/perl
# mpc search play
use strict;
use warnings;
use IPC::Open2;
use Getopt::Long qw(GetOptions HelpMessage);

# CLI Flags/Variables
my $append_flag = 0;
my $prompt_str = 'Song(s)?';

GetOptions(
  'append|a' => \&set_append_and_prompt,
  'help|h' => sub { HelpMessage(0) },
) or HelpMessage(1);

my @songs = grep { ! /\.git/ } `mpc listall`;
my $dmenu_songs_str = join('', @songs);
my $selections_ref = pipe_to_dmenu($dmenu_songs_str, $prompt_str);

if (@{$selections_ref}) {
  system("mpc clear") unless $append_flag;
  system("mpc", "add", @{$selections_ref});
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

# This should only be called by GetOptions
sub set_append_and_prompt {
  $append_flag = 1;
  # Prepend 'Append' to the original prompt
  $prompt_str = "Append $prompt_str";
}

=head1 NAME

msp.pl - mpc search play

=head1 SYNOPSIS

msp.pl [OPTION]

  -a, --append     Append selection(s) to current queue
  -h, --help       Print this help and exit

For more detailed documentation, run C<perldoc msp.pl>

=cut
