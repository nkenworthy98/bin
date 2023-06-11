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

    my %article_info;
    $article_info{'feed'} = parse_associated_value(\@pane_contents, "Feed");
    $article_info{'title'} = parse_associated_value(\@pane_contents, "Title");
    $article_info{'author'} = parse_associated_value(\@pane_contents, "Author");
    $article_info{'date'} = parse_associated_value(\@pane_contents, "Date");
    $article_info{'link'} = parse_associated_value(\@pane_contents, "Link");

    my @output;
    my $todo_line = "* TODO [[$article_info{'link'}][$article_info{'title'}]]\n";
    my $scheduled_line = "SCHEDULED: <$date_str>\n";
    push(@output, $todo_line);
    push(@output, $scheduled_line);
    push(@output, ":PROPERTIES:\n");

    foreach my $key (sort keys %article_info) {
        if (exists $article_info{$key} && $article_info{$key}) {
            push(@output, sprintf(":%s: %s\n", ucfirst $key, $article_info{$key}));
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

    print "$article_info{'title'} appended to $later_file\n";
}

sub parse_associated_value {
    my ($lines_ref, $str) = @_;

    foreach my $line (@{$lines_ref}) {
        if ($line =~ /^$str: (.*?)\s*$/) {
            return $1;
        }
    }
}
