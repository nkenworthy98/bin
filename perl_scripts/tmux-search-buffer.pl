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
        my $lines_ref = prompt_and_filter_lines($tmp_file);
        print "$_\n" for @{$lines_ref};
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

    print STDERR "Search?\n";
    my $regex = <STDIN>;
    chomp($regex);

    my @matching_lines;
    open (my $fh, '<', $file)
        or die "Error when opening $file: $!";

    while (my $line = <$fh>) {
        chomp($line);
        if ($line =~ /($regex)/i) {
            my $colored_match = colored($1, 'bold red');

            # my @matches = ($line =~ /($regex)/gi);
            # foreach my $match (@matches) {

            # }
            $line =~ s/\Q$1\E/$colored_match/;
            my $part_of_line;

            if ($line =~ m{^(.*\Q$colored_match\E)}) {
                $part_of_line = $1;
            }

            print "part of line: $part_of_line\n";
            push(@matching_lines, $line);
        }
    }

    close($fh)
        or die "Error when closing $file: $!";

    return \@matching_lines;
}
