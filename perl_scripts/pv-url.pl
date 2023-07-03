#!/usr/bin/perl
# Parse youtube/invidious url from tmux pane and open comments in another winodw
# using pipe-viewer
use strict;
use warnings;

my @tmux_pane_contents = `tmux capture-pane -p`;
chomp(@tmux_pane_contents);

my $vid_url;
foreach my $line (reverse @tmux_pane_contents) {
    # url from pipe-viewer
    if ($line =~ m{^=> URL: (https://.*?)\s*$}) {
        my $invidious_instance = `grii.sh`;
        chomp($invidious_instance);
        my $invidious_url = $1 =~ s/www\.youtube\.com/$invidious_instance/r;
        $vid_url = $invidious_url;
        last;
    }
    # invidious url from rss feed in newsboat
    elsif ($line =~ m{^\[1\]: (https://.*?)\s\(link\)\s*$}) {
        $vid_url = $1;
        last;
    }
}

if ($vid_url) {
    system("tmux new-window -n comments");
    my $cmd = qq(pipe-viewer --comments "$vid_url");
    system("tmux send-keys '$cmd' Enter\;");
}
elsif ($ENV{'TMUX'}) {
    my $tmux_message = "Unable to find pipe-viewer url in current window";
    system("tmux display-message -d 2000 '$tmux_message'");
}
else {
    die "Unable to find pipe-viewer url in current window: $!";
}
