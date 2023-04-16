#!/usr/bin/perl
# Dump the contents of all sessions/windows/panes running in tmux
use strict;
use warnings;
use File::Path;
use POSIX qw(strftime);

my $timestamp = strftime("%F_%T", localtime) =~ s/:/-/gr;
my $output_dir = "/tmp/tmux-dump-$timestamp";

my @tmux_sessions_output = `tmux list-sessions`;
foreach my $session_line (@tmux_sessions_output) {
    my $session = parse_session_name($session_line);

    my @tmux_windows_output = `tmux list-windows -t $session`;
    foreach my $window_line (@tmux_windows_output) {
        my $window = parse_number_at_line_start($window_line);
        my $window_name = parse_window_name($window_line);

        my @tmux_panes_output = `tmux list-panes -t $session:$window`;
        foreach my $pane_line (@tmux_panes_output) {
            my $pane = parse_number_at_line_start($pane_line);

            my $window_pane_path = "$output_dir/$session/window-$window/pane-$pane";
            mkpath($window_pane_path);
            chdir($window_pane_path);

            my $window_and_pane = "$window.$pane";
            system("tmux capture-pane -t '$session:$window_and_pane' -e -S - -J");
            system("tmux save-buffer '$window_and_pane-$window_name.txt'");
        }
    }
}

print "tmux dump written to '$output_dir'\n";

sub parse_session_name {
    my ($session_line) = @_;

    chomp($session_line);
    if ($session_line =~ /^(.*?):/) {
        return $1;
    }
    else {
        die "Unable to parse tmux session name: $!";
    }
}

sub parse_number_at_line_start {
    my ($line) = @_;

    chomp($line);
    if ($line =~ /^(\d+):/) {
        return $1;
    }
    else {
        die "Unable to parse number at line start: $!";
    }
}

sub parse_window_name {
    my ($line) = @_;

    chomp($line);
    if ($line =~ /^\d+: (.*?)[\*-]? \(\d+ panes\)/) {
        return $1;
    }
    else {
        die "Unable to parse window name: $!";
    }
}
