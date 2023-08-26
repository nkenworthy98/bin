#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions HelpMessage);
use Term::ANSIColor qw(colored);

my $tmp_file = '/tmp/tmux-search-buffer.txt';

GetOptions(
    'help|h' => sub { HelpMessage(0) },
    'prompt|p' => sub {
        prompt_and_filter_lines($tmp_file);
        exit;
    },
) or HelpMessage(1);

system("tmux capture-pane -S - -J -p > $tmp_file");
system("tmux new-window -n search");
system("tmux send-keys 'tmux-search-buffer.pl --prompt' Enter\;");

sub prompt_and_filter_lines {
    my ($file) = @_;

    my $regex;
    unless ($regex = $ARGV[0]) {
        print STDERR "Search?\n";
        $regex = <STDIN>;
        chomp($regex);
    }

    open (my $fh, '<', $file)
        or die "Error when opening $file: $!";

    while (my $line = <$fh>) {
        chomp($line);
        if ($line =~ /$regex/i) {
            $line =~ s/($regex)/colored($1, 'bold red')/egi;
            print $line, "\n";
        }
    }

    close($fh)
        or die "Error when closing $file: $!";
}

=head1 NAME

tmux-search-buffer.pl

=head1 DESCRIPTION

Capture the contents of the current tmux pane and write to a tmp file
(/tmp/tmux-search-buffer.txt).
Next, open a new window, and prompt the user to type in a regular expression.
Matching substrings will be printed in color.

=head1 SYNOPSIS

  -h, --help    Print this help and quit
  -p, --prompt  Prompt the user for a regex to parse capture-pane contents
                    (note: parses /tmp/tmux-search-buffer.txt)

For more detailed documentation, run C<perldoc tmux-search-buffer.pl>

=cut
