#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions HelpMessage);
use Term::ANSIColor qw(colored);

my $tmp_file = '/tmp/tmux-search-buffer.txt';
my $tmux_active_regex = qr{^(\d+):.*?\(active\)};

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

sub parse_number_at_line_start {
    my ($line) = @_;

    if ($line =~ /^(\d+):/) {
        return $1;
    }
    else {
        die "Unable to parse number at line start: $!";
    }
}

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
            my @matches = ($line =~ /($regex)/gi);
            my @parts;

            foreach my $match (@matches) {
                my $colored_match = colored($match, 'bold red');

                my $match_index = index($line, $match);
                my $match_len = length($match);
                substr($line, $match_index, $match_len, $colored_match);

                # # remove part of line through $colored_match, so the remaining
                # # matches can continue to be highlighted without affecting the
                # # substrings that have already been highlighted
                my $colored_index = index($line, $colored_match);
                my $colored_match_len = length($colored_match);
                my $index_after_match = $colored_index + $colored_match_len;
                my $part_with_match = substr($line, 0, $index_after_match);
                my $remaining_part = substr($line, $index_after_match);

                push(@parts, $part_with_match);
                $line = $remaining_part;

            }

            # add the remaining part of the line that doesn't have any more
            # matches
            push(@parts, $line);
            my $colored_line = join('', @parts);
            print $colored_line, "\n";
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
