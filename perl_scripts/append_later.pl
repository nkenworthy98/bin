#!/usr/bin/perl
# Meant to be called using a tmux keybinding while in an article
use strict;
use warnings;
use List::Util qw(first);

my $date_str = `date "+%F %a"`;
chomp($date_str);
my $later_file = "$ENV{'HOME'}/.emacsOrgFiles/org/later.org";

if ($ENV{'TMUX'}) {
    my @pane_contents = `tmux capture-pane -J -p`;
    chomp(@pane_contents);

    my $feed = parse_associated_value(\@pane_contents, "Feed");
    my $title = parse_associated_value(\@pane_contents, "Title");
    my $author = parse_associated_value(\@pane_contents, "Author");
    my $date = parse_associated_value(\@pane_contents, "Date");
    my $link = parse_associated_value(\@pane_contents, "Link");

    my @output;
    my $todo_line = "* TODO [[$link][$title]]\n";
    my $scheduled_line = "SCHEDULED: <$date_str>\n";
    push(@output, $todo_line);
    push(@output, $scheduled_line);
    push(@output, ":PROPERTIES:\n");
    push(@output, ":Feed: $feed\n");
    push(@output, ":Title: $title\n");
    push(@output, ":Author: $author\n");
    push(@output, ":Date: $date\n");
    push(@output, ":Link: $link\n");
    push(@output, ":END:\n");

    open (my $fh, '>>', $later_file)
        or die "Error opening $later_file";

    foreach my $line (@output) {
        print $fh $line;
    }

    close($fh)
        or die "Error closing $later_file";

    print "$title appended to $later_file\n";
}

sub parse_associated_value {
    my ($lines_ref, $str) = @_;

    foreach my $line (@{$lines_ref}) {
        if ($line =~ /^$str: (.*?)\s*$/) {
            return $1;
        }
    }

    die "$str associated value not found";
}
