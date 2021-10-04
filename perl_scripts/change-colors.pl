#!/usr/bin/perl
# Script to change colors in all the main programs I use.
use strict;
use warnings;

# MAIN_CUSTOM_COLOR environment variable is expected to be
# set in your shell's rc file in the following format:
#
# export MAIN_CUSTOM_COLOR='#235481'

my $new_color = $ENV{'MAIN_CUSTOM_COLOR'};
my $home = $ENV{'HOME'};
my $path_shellrc = "$home/.zshrc";
my $path_tmux_conf = "$home/.tmux.conf";
my $path_dunst_conf = "$home/.config/dunst/dunstrc";
my $path_ncmpcpp_conf = "$home/.config/ncmpcpp/config";
# The paths for the suckless programs expect to have a trailing "/"
my $path_dwm = "$home/.sucklessPrograms/dwm/";
my $path_dmenu = "$home/.sucklessPrograms/dmenu/";

is_hex_color_code($new_color) or die "ERROR: $new_color isn't a valid hex color code";

change_tmux_colors($new_color, $path_tmux_conf);
change_dwm_colors($new_color, $path_dwm);
change_dmenu_colors($new_color, $path_dmenu);
change_dunst_colors($new_color, $path_dunst_conf);
change_ncmpcpp_colors($new_color, $path_ncmpcpp_conf);
change_nnn_colors($new_color, $path_shellrc); # nnn colors are defined in shell's rc

sub is_hex_color_code {
  my $num = shift @_;

  # Returns 1 if passed in value is a valid hex color code
  # Else, returns 0
  return ($num =~ /\A#[0-9a-f]{6}\z/i);
}

sub change_tmux_colors {
  my ($color, $path_conf) = @_;
  open(my $tmux_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  my @tmux_contents;

  # Substitute necessary lines to change foreground color of tmux status bar
  while (<$tmux_in>) {
    if (/set -g pane-active-border-style fg='#[0-9a-f]{6}'/i
        || /set-option -g status-style fg='#[0-9a-f]{6}'/i
        || /set-option -g message-style fg='#[0-9a-f]{6}'/i
        || /set-option -g status-style fg='#[0-9a-f]{6}'/i
        || /set -g status-right "#\[fg=#[0-9a-f]{6}\]%A, %d %b %Y %I:%M %p"/i) {
      s/#[0-9a-f]{6}/$color/i;
    }
    push(@tmux_contents, $_);
  }
  close $tmux_in or die "$tmux_in: $!";

  # Write all the lines to the same file
  open(my $tmux_out, ">", $path_conf) or die "Can't open $path_conf: $!";
  foreach (@tmux_contents) {
    print $tmux_out $_;
  }
  close $tmux_out or die "$tmux_out: $!";
}

sub change_dunst_colors {
  my ($color, $path_conf) = @_;
  open (my $dunst_in, "<", $path_conf) or die "Can't open $path_conf";

  my @dunst_contents;
  my $is_first_instance = 1;

  # Substitute only first instance of frame_color. There's another instance that is
  # found in the urgency section, and I don't want it changed.
  while (<$dunst_in>) {
    if (/frame_color = "#[0-9a-f]{6}"/i && $is_first_instance) {
      s/#[0-9a-f]{6}/$color/i;
      $is_first_instance = 0;
    }
    push(@dunst_contents, $_);
  }
  close $dunst_in or die "$dunst_in: $!";

  # Write contents back to dunstrc
  open(my $dunst_out, ">", $path_conf) or die "Can't open $path_conf: $!";
  foreach (@dunst_contents) {
    print $dunst_out $_;
  }
  close $dunst_out or die "$dunst_out: $!";
}

sub change_dwm_colors {
  my ($color, $path) = @_;
  my $path_conf = $path . "config.h";

  open(my $dwm_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  my @dwm_contents;

  # Substitute the line with necessary change
  while (<$dwm_in>) {
    if (/static const char col_cyan\[\]\s+= "#[0-9a-f]{6}";/i) {
      s/#[0-9a-f]{6}/$color/i;
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

  # Compile and install dwm with changes
  chdir $path;
  my $make_install_output = `sudo make install`;
  print $make_install_output;
}

sub change_dmenu_colors {
  my ($color, $path) = @_;
  my $path_conf = $path . "config.h";

  open(my $dmenu_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  my @dmenu_contents;

  # Substitute the line with necessary change
  while (<$dmenu_in>) {
    if (/\[SchemeSel\] = \{ "#ffffff", "(?<select_color>#[0-9a-f]{6})" \}/i) {
      s/$+{select_color}/$color/i;
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

  # Compile and install dmenu with changes
  chdir $path;
  my $make_install_output = `sudo make install`;
  print $make_install_output;
}

sub change_ncmpcpp_colors {
  my ($color, $path_conf) = @_;
  open(my $ncmpcpp_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  # Rather than dealing with codes 0-255, ncmpcpp
  # deals with 1-256, so 1 needs to be added
  chomp(my $color_256 = `hex-to-256.pl "$color"`);

  # Don't want colors to go beyond 256,
  $color_256 = ($color_256 + 1) % 256 ;

  my @visualizer_colors = set_ncmpcpp_visualizer_colors($color_256);
  my $vc_replacement = join(",", @visualizer_colors);

  my @ncmpcpp_contents;

  while (<$ncmpcpp_in>) {
    if (/\Avisualizer_color = (?<current_colors>.*)\Z/) {
      s/$+{current_colors}/$vc_replacement/;
    }
    push(@ncmpcpp_contents, $_);
  }
  close $ncmpcpp_in or die "$ncmpcpp_in: $!";

  # Write contents back to ncmpcpp config
  open(my $ncmpcpp_out, ">", $path_conf) or die "Can't open $path_conf: $!";
  foreach (@ncmpcpp_contents) {
    print $ncmpcpp_out $_;
  }
  close $ncmpcpp_out or die "$ncmpcpp_out: $!";

}

sub set_ncmpcpp_visualizer_colors {
  my $color = shift @_;

  my @visualizer_colors;
  # Make sure passed in color is in the
  # visualizer_colors list
  push(@visualizer_colors, $color);

  my $counter = 0;
  # I want the visualizer to have 10 colors in total
  # These colors will start at the one returned from hex-to-256.pl
  # and increment by 1 until there's 10 colors in total
  while ($counter < 9) {
    $color = ($color + 1) % 256;
    push(@visualizer_colors, $color);
    $counter += 1;
  }

  return @visualizer_colors;
}

sub change_nnn_colors {
  my ($color, $path_conf) = @_;
  open(my $nnn_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  chomp(my $color_256 = `hex-to-256.pl "$color"`);

  my $colors_replacement = set_nnn_colors($color_256);
  my @nnn_contents;

  while (<$nnn_in>) {
    if (/\Aexport NNN_COLORS='(?<current_colors>.*)'\Z/) {
      s/$+{current_colors}/$colors_replacement/;
    }
    push(@nnn_contents, $_);
  }
  close $nnn_in or die "$nnn_in: $!";

  open(my $nnn_out, ">", $path_conf) or die "Can't open $path_conf: $!";
  foreach (@nnn_contents) {
    print $nnn_out $_;
  }
  close $nnn_out or die "$nnn_out: $!";
}

sub set_nnn_colors {
  my $color = shift @_;

  my @nnn_colors = "#";
  my $counter = 0;
  # while counter is < 4 because nnn expects 4 colors for
  # the 4 contexts that can be used. Also, I want
  # to increment the colors
  while ($counter < 4) {
    # nnn uses hex colors (0x00-0xFF), so
    # the 256 color needs to be converted
    my $hex_equivalent = sprintf("%x", $color);

    # According to nnn man page when using the 256 colors,
    # there must be 2 symbols per context
    if (length($hex_equivalent) == 1) {
      $hex_equivalent = "0" . $hex_equivalent;
    }

    push(@nnn_colors, $hex_equivalent);
    # Make sure color doesn't go beyond 255
    $color = ($color + 1) % 256;
    $counter += 1 ;
  }
  # Include default colors at the end in case
  # the hex colors aren't supported
  push(@nnn_colors, ";4531");
  # Convert the array to a string to be returned
  my $colors_string = join("", @nnn_colors);
  return $colors_string;
}
