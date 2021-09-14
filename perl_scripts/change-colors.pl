#!/usr/bin/perl
# Script to change colors in all the main programs I use.
use strict;
use warnings;

my $new_color = $ENV{'MAIN_CUSTOM_COLOR'};
my $home = $ENV{'HOME'};
my $path_tmux_conf = "$home/.tmux.conf";
# The paths for the suckless programs expect to have a trailing "/"
my $path_dwm = "$home/.sucklessPrograms/dwm/";
my $path_dmenu = "$home/.sucklessPrograms/dmenu/";

is_hex($new_color) or die "ERROR: $new_color isn't a hexadecimal number";

change_tmux_colors($new_color, $path_tmux_conf);
change_dwm_colors($new_color, $path_dwm);
change_dmenu_colors($new_color, $path_dmenu);

sub is_hex {
  my $num = shift @_;

  if ($num =~ /\A#[a-fA-F0-9]{6}\z/) {
    return 1;
  } else {
    return 0;
  }
}

sub change_tmux_colors {
  my ($color, $path_conf) = @_;
  open(my $tmux_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  my @tmux_contents;

  # Substitute necessary lines to change foreground color of tmux status bar
  while (<$tmux_in>) {
    if (/set -g pane-active-border-style fg='#[a-fA-F0-9]{6}'/
        || /set-option -g status-style fg='#[a-fA-F0-9]{6}'/
        || /set-option -g message-style fg='#[a-fA-F0-9]{6}'/
        || /set-option -g status-style fg='#[a-fA-f0-9]{6}'/
        || /set -g status-right "#\[fg=#[a-fA-F0-9]{6}\]%A, %d %b %Y %I:%M %p"/) {
      s/#[a-fA-f0-9]{6}/$color/;
    }
    push(@tmux_contents, $_);
  }
  close $tmux_in or die "$tmux_in: $!\n";

  # Write all the lines to the same file
  open(my $tmux_out, ">", $path_conf) or die "Can't open $path_conf: $!";
  foreach (@tmux_contents) {
    print $tmux_out $_;
  }
  close $tmux_out or die "$tmux_out: $!";
}

sub change_dwm_colors {
  my ($color, $path) = @_;
  my $path_conf = $path . "config.h";

  open(my $dwm_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  my @dwm_contents;

  # Substitute the line with necessary change
  while (<$dwm_in>) {
    if (/static const char col_cyan\[\]\s+= "#[a-fA-F0-9]{6}";/) {
      s/#[a-fA-F0-9]{6}/$color/;
    }
    push(@dwm_contents, $_);
  }
  close $dwm_in or die "$dwm_in: $!";

  # Write all the lines to the same file
  open(my $dwm_out, ">", $path_conf);
  foreach (@dwm_contents) {
    print $dwm_out $_;
  }
  close $dwm_out or die "$dwm_out: $!";

  # Compile dwm with changes
  chdir $path;
  my $make_output = `make`;
  print $make_output;
}

sub change_dmenu_colors {
  my ($color, $path) = @_;
  my $path_conf = $path . "config.h";

  open(my $dmenu_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  my @dmenu_contents;

  # Substitute the line with necessary change
  while (<$dmenu_in>) {
    if (/\[SchemeSel\] = \{ "#ffffff", "(?<select_color>#[a-fA-F0-9]{6})" \}/) {
      s/$+{select_color}/$color/;
    }
    push(@dmenu_contents, $_);
  }
  close $dmenu_in or die "$dmenu_in: $!";

  # Write all the lines to the same file
  open(my $dmenu_out, ">", $path_conf);
  foreach (@dmenu_contents) {
    print $dmenu_out $_;
  }
  close $dmenu_out or die "$dmenu_out: $!";

  # Compile dmenu with changes
  chdir $path;
  my $make_output = `make`;
  print $make_output;
}
