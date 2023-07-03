#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(first);

my @tmux_pane_contents = `tmux capture-pane -p`;
my $vid_url = first { $_ }
              map { m{^=> URL: (https://.*?)\s+$} ? ($1) : () }
              reverse
              @tmux_pane_contents;

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
