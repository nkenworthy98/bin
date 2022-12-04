#!/usr/bin/perl
# Script to change colors in all the main programs I use.
use strict;
use warnings;
use Getopt::Long qw(GetOptions HelpMessage);
use File::Slurper qw(read_lines write_text);

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

GetOptions(
  # Takes precedence over MAIN_CUSTOM_COLOR and sets it
  'color|c=s' => \$new_color,
  'help|h' => sub { HelpMessage(0) },
) or HelpMessage(1);

is_hex_color_code($new_color) or die "ERROR: $new_color isn't a valid hex color code";

# If user forces a new color using --color, update MAIN_CUSTOM_COLOR in shell's
# rc, so programs that read this value in order to set colors use --color
if ($new_color ne $ENV{'MAIN_CUSTOM_COLOR'}) {
  change_main_custom_color_in_rc($new_color, $path_shellrc);
}

change_tmux_colors($new_color, $path_tmux_conf);
change_dwm_colors($new_color, $path_dwm);
change_dmenu_colors($new_color, $path_dmenu);
change_dunst_colors($new_color, $path_dunst_conf);
change_ncmpcpp_colors($new_color, $path_ncmpcpp_conf);
# change_nnn_colors($new_color, $path_shellrc); # nnn colors are defined in shell's rc

sub is_hex_color_code {
  my $num = shift @_;

  # Returns 1 if passed in value is a valid hex color code
  # Else, returns 0
  return ($num =~ /\A#[0-9a-f]{6}\z/i);
}

sub update_file_with_changes {
  my ($file, $changes_hashref) = @_;

  print "Updating '$file'...\n";

  my @original_lines = read_lines($file);
  my @changed_lines = map { update_line_with_changes($_, $changes_hashref) } @original_lines;
  write_text($file, join("\n", @changed_lines));

  print "Successfully updated '$file'\n"
}

sub update_line_with_changes {
  my ($line, $changes_hashref) = @_;

  foreach my $key (keys %{$changes_hashref}) {
    if ($line =~ $key) {
      $line =~ s/$1/$changes_hashref->{$key}/;
    }
  }

  return $line;
}

sub change_main_custom_color_in_rc {
  my ($color, $path_conf) = @_;

  my %rc_changes = (
    qr{^export MAIN_CUSTOM_COLOR='(#[0-9a-fA-F]{6})'} => $color,
  );

  update_file_with_changes($path_conf, \%rc_changes);
}


sub change_tmux_colors {
  my ($color, $path_conf) = @_;

  my %tmux_changes = (
    qr{^set -g pane-active-border-style fg='(#[0-9a-f]{6})'}i => $color,
    qr{^set-option -g status-style fg='(#[0-9a-f]{6})'}i => $color,
    qr{^set-option -g message-style fg='(#[0-9a-f]{6})'}i => $color,
    qr{^set -g status-right "#\[fg=(#[0-9a-f]{6})\]}i => $color,
  );

  update_file_with_changes($path_conf, \%tmux_changes);
}

sub change_dunst_colors {
  my ($color, $path_conf) = @_;

  my %dunst_changes = (
    # make sure '# global' comes after this line, so other instances of
    # frame_color don't get changed
    qr{frame_color = "(#[0-9a-f]{6})" # global}i => $color,
  );

  update_file_with_changes($path_conf, \%dunst_changes);
}

sub change_dwm_colors {
  my ($color, $path) = @_;
  my $path_conf = $path . "config.h";

  my %dwm_changes = (
    qr{static const char col_cyan\[\]\s+= "(#[0-9a-f]{6})";}i => $color,
  );

  update_file_with_changes($path_conf, \%dwm_changes);

  # Compile and install dwm with changes
  chdir $path;
  my $make_install_output = `sudo make install`;
  print $make_install_output;
}

sub change_dmenu_colors {
  my ($color, $path) = @_;
  my $path_conf = $path . "config.h";

  my %dmenu_changes = (
    qr{\[SchemeSel\] = \{ "#ffffff", "(#[0-9a-f]{6})" \}}i => $color,
  );

  update_file_with_changes($path_conf, \%dmenu_changes);

  # Compile and install dmenu with changes
  chdir $path;
  my $make_install_output = `sudo make install`;
  print $make_install_output;
}

sub change_ncmpcpp_colors {
  my ($color, $path_conf) = @_;

  # Rather than dealing with codes 0-255, ncmpcpp
  # deals with 1-256, so 1 needs to be added
  chomp(my $color_256 = `hex-to-256.pl --unweighted "$color"`);

  # Don't want colors to go beyond 256,
  $color_256 = ($color_256 + 1) % 256 ;

  my @visualizer_colors = set_ncmpcpp_visualizer_colors($color_256);
  my $vc_replacement = join(",", @visualizer_colors);

  # Replace colors of various UI elements. See the comments below for
  # example lines that will match with the regular expressions
  my %ncmpcpp_changes = (
    qr{^visualizer_color = (.*)$}i => $vc_replacement,
    # main_window_color = 39
    qr{^main_window_color = (.*)$}i => $color_256,
    # song_columns_list_format = (20)[17]{a} (6f)[green]{NE} (50)[white]{t|f:Title} (20)[cyan]{b} (7f)[magenta]{l}
    qr{^song_columns_list_format = \(20\)\[(.*)\]\{a\}}i => $color_256,
    # current_item_prefix = $(177)$r
    qr{^current_item_prefix = \$\((.*)\)\$r$}i => $color_256,
    # alternative_header_second_line_format = {{$(11)$b%a$/b$9}{ - $7%b$9}{ ($5%y$9)}}|{%D}
    # Assumes previous_color is inside parentheses in ncmpcpp config and is a number
    qr{^alternative_header_second_line_format = \{\{\$\((\d+)\)\$}i => $color_256,
  );

  update_file_with_changes($path_conf, \%ncmpcpp_changes);

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
    $color = ($color % 256) + 1;
    push(@visualizer_colors, $color);
    $counter += 1;
  }

  return @visualizer_colors;
}

sub change_nnn_colors {
  my ($color, $path_conf) = @_;
  open(my $nnn_in, "<", $path_conf) or die "Can't open $path_conf: $!";

  chomp(my $color_256 = `hex-to-256.pl --unweighted "$color"`);

  my $colors_replacement = set_nnn_colors($color_256);
  my @nnn_contents;

  while (<$nnn_in>) {
    if (/\Aexport NNN_COLORS='(?<previous_colors>.*)'\Z/) {
      s/$+{previous_colors}/$colors_replacement/;
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

=head1 NAME

change-color.pl - Change the colors in some of the programs that I use

=head1 DESCRIPTION

Change the colors in some of the main programs that I use.
These programs include tmux, dwm, dmenu, dunst, ncmpcpp, and nnn.
By default, it reads the users's shell rc for a variable MAIN_CUSTOM_COLOR (in the form #123123).
A user can also pass --color #123123 in order to set this value.

=head1 SYNOPSIS

  -c, --color COLOR   Set the main color to be used
                        (note: color should be in the form #123123)
  -h, --help          Print this help and quit

For more detailed documentation, run C<perldoc change-colors.pl>.

=cut
