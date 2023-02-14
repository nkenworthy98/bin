#!/usr/bin/perl
# Hacky way of being able to display music album art in terminal
#
# Uses nnn, ueberzug, tmux, and nnn's preview-tui plugin in order to accomplish this
use strict;
use warnings;

my $session_name = 'ncmppcp-preview';

if (grep { /^$session_name:/ } `tmux ls`) {
  system("tmux kill-session -t '$session_name'");
}

my $music_dir = "$ENV{HOME}/.Music";
my $relative_music_path = `mpc status -f '%file%' | head -n 1`;
# Newline at end can cause issues, so remove it
chomp($relative_music_path);
my $full_music_path = "$music_dir/$relative_music_path";

# If '%file%' is a cue file ending in with track, substitute it out
# Without this, this program won't be able to navigate to the proper directory
# Will convert something like:
#   ~/.Music/CDImage.cue/track0001
#   to
#   ~/.Music/CDImage.cue
# which makes is a path that can be navigated to
if ($full_music_path =~ /\.cue(?<cue_track>\/track\d+\Z)/) {
  $full_music_path =~ s/$+{cue_track}//;
}

# 'p' is the plugin key I have for nnn in order to use preview-tui
system(qq(tmux new-session -s $session_name -d nnn -P p "$full_music_path"));
system("tmux switch-client -t '$session_name'");
