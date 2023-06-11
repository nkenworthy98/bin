#!/usr/bin/perl
# Meant to be called using a tmux keybinding while in an article
# Appends a new watch/read later entry to my org file
use strict;
use warnings;
use List::Util qw(first);

my $date_str = `date "+%F %a"`;
chomp($date_str);
my $later_file = "$ENV{'HOME'}/.emacsOrgFiles/org/later.org";

if ($ENV{'TMUX'}) {
    my @pane_contents = `tmux capture-pane -J -p`;
    chomp(@pane_contents);

    # Shift off "Newsboat" line at top of pane
    shift(@pane_contents);

    my %article_info;

    # Grab things like 'Feed', 'Title', and 'Date' from pane contents
    foreach my $line (@pane_contents) {
        # Feed, Title, Date, etc., is in the first block of text in an article,
        # and the blocks are separated by empty lines
        last if ($line =~ /^\s*$/);

        # Example line in article that will match:
        #
        # Feed: My Feed Here
        #
        # "Feed" is the key
        # "My Feed Here" is the value
        #
        # Long lines (usually long URLs) can cause value to start on next line
        # Don't bother adding to %article_info if value isn't extracted
        if ($line =~ /^(.*?): (.*?)\s*$/ && $2 !~ /^\s*$/) {
            my $key = $1;
            my $value = $2;
            my $key_without_spaces = $key =~ s/\s//gr;
            $article_info{$key_without_spaces} = $value;
        }
    }

    my $has_feed = exists $article_info{'Feed'} && $article_info{'Feed'} ne "";
    my $has_title = exists $article_info{'Title'} && $article_info{'Title'} ne "";
    my $has_link = exists $article_info{'Link'} && $article_info{'Link'} ne "";

    # All newsboat articles have these values
    unless ($has_feed && $has_title && $has_link) {
        my $missing_info_msg = <<"MISSING_INFO_MSG";
Error: missing feed, title, and/or link
Make sure $0 was run within a newsboat article
MISSING_INFO_MSG
        die $missing_info_msg;
    }

    my @output;
    my $todo_line = "* TODO [[$article_info{'Link'}][$article_info{'Title'}]]\n";
    my $scheduled_line = "SCHEDULED: <$date_str>\n";
    push(@output, $todo_line);
    push(@output, $scheduled_line);
    push(@output, ":PROPERTIES:\n");

    foreach my $key (sort keys %article_info) {
        if (exists $article_info{$key} && $article_info{$key}) {
            push(@output, sprintf(":%s: %s\n", $key, $article_info{$key}));
        }
    }

    push(@output, ":END:\n");

    open (my $fh, '>>', $later_file)
        or die "Error opening $later_file";

    foreach my $line (@output) {
        print $fh $line;
    }

    close($fh)
        or die "Error closing $later_file";

    print "$article_info{'Title'} appended to $later_file\n";
}
else {
    die "Error: this must run within tmux";
}
