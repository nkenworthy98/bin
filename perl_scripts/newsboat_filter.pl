#!/usr/bin/perl
# Open newsboat tmux session with a feedtitle filter entered through dmenu
use strict;
use warnings;
use File::Copy;
use File::Temp qw(tempfile);

if (grep { /(?!grep) newsboat/ } `ps aux`) {
    system("killall newsboat");
}

unless ($ENV{'TMUX'}) {
    die "Error: not currently in a tmux session";
}

my $newsboat_session_name = "newsboat";
if (grep { /^$newsboat_session_name:/ } `tmux list-sessions`) {
    system("tmux kill-session $newsboat_session_name");
}

my $newsboat_config = "$ENV{'HOME'}/.config/newsboat/config";
my ($fh, $tmpfile) = tempfile();
copy($newsboat_config, $tmpfile);

my $title = `printf '' | dmenu -p "Newsboat Title?"`;
chomp($title);

my $filter = qq(run-on-startup select-tag YouTube; set-filter "feedtitle =~ \\"$title\\""\n);

open ($fh, '>>', $tmpfile)
    or die "Error when opening '$tmpfile'";
print $fh $filter;
close($fh)
    or die "Error when closing '$tmpfile'";

system("tmux new-session -s $newsboat_session_name -d newsboat -C $tmpfile");
system("tmux switch-client -t $newsboat_session_name");
unlink($tmpfile);
