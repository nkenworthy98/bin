#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long qw(GetOptions HelpMessage);

# CLI Flags
my $use_unweighted = 0;

GetOptions(
  'unweighted|u' => \$use_unweighted,
  'help|h' => sub { HelpMessage(0) },
) or HelpMessage(1);

my @colors_256 = (
  '#000000',
  '#800000',
  '#008000',
  '#808000',
  '#000080',
  '#800080',
  '#008080',
  '#c0c0c0',
  '#808080',
  '#ff0000',
  '#00ff00',
  '#ffff00',
  '#0000ff',
  '#ff00ff',
  '#00ffff',
  '#ffffff',
  '#000000',
  '#00005f',
  '#000087',
  '#0000af',
  '#0000d7',
  '#0000ff',
  '#005f00',
  '#005f5f',
  '#005f87',
  '#005faf',
  '#005fd7',
  '#005fff',
  '#008700',
  '#00875f',
  '#008787',
  '#0087af',
  '#0087d7',
  '#0087ff',
  '#00af00',
  '#00af5f',
  '#00af87',
  '#00afaf',
  '#00afd7',
  '#00afff',
  '#00d700',
  '#00d75f',
  '#00d787',
  '#00d7af',
  '#00d7d7',
  '#00d7ff',
  '#00ff00',
  '#00ff5f',
  '#00ff87',
  '#00ffaf',
  '#00ffd7',
  '#00ffff',
  '#5f0000',
  '#5f005f',
  '#5f0087',
  '#5f00af',
  '#5f00d7',
  '#5f00ff',
  '#5f5f00',
  '#5f5f5f',
  '#5f5f87',
  '#5f5faf',
  '#5f5fd7',
  '#5f5fff',
  '#5f8700',
  '#5f875f',
  '#5f8787',
  '#5f87af',
  '#5f87d7',
  '#5f87ff',
  '#5faf00',
  '#5faf5f',
  '#5faf87',
  '#5fafaf',
  '#5fafd7',
  '#5fafff',
  '#5fd700',
  '#5fd75f',
  '#5fd787',
  '#5fd7af',
  '#5fd7d7',
  '#5fd7ff',
  '#5fff00',
  '#5fff5f',
  '#5fff87',
  '#5fffaf',
  '#5fffd7',
  '#5fffff',
  '#870000',
  '#87005f',
  '#870087',
  '#8700af',
  '#8700d7',
  '#8700ff',
  '#875f00',
  '#875f5f',
  '#875f87',
  '#875faf',
  '#875fd7',
  '#875fff',
  '#878700',
  '#87875f',
  '#878787',
  '#8787af',
  '#8787d7',
  '#8787ff',
  '#87af00',
  '#87af5f',
  '#87af87',
  '#87afaf',
  '#87afd7',
  '#87afff',
  '#87d700',
  '#87d75f',
  '#87d787',
  '#87d7af',
  '#87d7d7',
  '#87d7ff',
  '#87ff00',
  '#87ff5f',
  '#87ff87',
  '#87ffaf',
  '#87ffd7',
  '#87ffff',
  '#af0000',
  '#af005f',
  '#af0087',
  '#af00af',
  '#af00d7',
  '#af00ff',
  '#af5f00',
  '#af5f5f',
  '#af5f87',
  '#af5faf',
  '#af5fd7',
  '#af5fff',
  '#af8700',
  '#af875f',
  '#af8787',
  '#af87af',
  '#af87d7',
  '#af87ff',
  '#afaf00',
  '#afaf5f',
  '#afaf87',
  '#afafaf',
  '#afafd7',
  '#afafff',
  '#afd700',
  '#afd75f',
  '#afd787',
  '#afd7af',
  '#afd7d7',
  '#afd7ff',
  '#afff00',
  '#afff5f',
  '#afff87',
  '#afffaf',
  '#afffd7',
  '#afffff',
  '#d70000',
  '#d7005f',
  '#d70087',
  '#d700af',
  '#d700d7',
  '#d700ff',
  '#d75f00',
  '#d75f5f',
  '#d75f87',
  '#d75faf',
  '#d75fd7',
  '#d75fff',
  '#d78700',
  '#d7875f',
  '#d78787',
  '#d787af',
  '#d787d7',
  '#d787ff',
  '#d7af00',
  '#d7af5f',
  '#d7af87',
  '#d7afaf',
  '#d7afd7',
  '#d7afff',
  '#d7d700',
  '#d7d75f',
  '#d7d787',
  '#d7d7af',
  '#d7d7d7',
  '#d7d7ff',
  '#d7ff00',
  '#d7ff5f',
  '#d7ff87',
  '#d7ffaf',
  '#d7ffd7',
  '#d7ffff',
  '#ff0000',
  '#ff005f',
  '#ff0087',
  '#ff00af',
  '#ff00d7',
  '#ff00ff',
  '#ff5f00',
  '#ff5f5f',
  '#ff5f87',
  '#ff5faf',
  '#ff5fd7',
  '#ff5fff',
  '#ff8700',
  '#ff875f',
  '#ff8787',
  '#ff87af',
  '#ff87d7',
  '#ff87ff',
  '#ffaf00',
  '#ffaf5f',
  '#ffaf87',
  '#ffafaf',
  '#ffafd7',
  '#ffafff',
  '#ffd700',
  '#ffd75f',
  '#ffd787',
  '#ffd7af',
  '#ffd7d7',
  '#ffd7ff',
  '#ffff00',
  '#ffff5f',
  '#ffff87',
  '#ffffaf',
  '#ffffd7',
  '#ffffff',
  '#080808',
  '#121212',
  '#1c1c1c',
  '#262626',
  '#303030',
  '#3a3a3a',
  '#444444',
  '#4e4e4e',
  '#585858',
  '#606060',
  '#666666',
  '#767676',
  '#808080',
  '#8a8a8a',
  '#949494',
  '#9e9e9e',
  '#a8a8a8',
  '#b2b2b2',
  '#bcbcbc',
  '#c6c6c6',
  '#d0d0d0',
  '#dadada',
  '#e4e4e4',
  '#eeeeee'
);

my $original_hex_color = $ARGV[0];

my $closest_256_color = get_closest_256_color($original_hex_color, @colors_256);
print "$closest_256_color\n";

sub calc_euclidean_distance {
  my ($color1, $color2) = @_;

  my ($red1, $green1, $blue1) = get_rgb($color1);
  my ($red2, $green2, $blue2) = get_rgb($color2);
  my $difference = '';


  # This is the unweighted calculation
  if ($use_unweighted) {
    $difference = sqrt(($red2-$red1)**2 + ($green2-$green1)**2 + ($blue2-$blue1)**2);
  }
  # This uses weighted values and should, in theory, result in values closer to human perception
  else {
    $difference = sqrt((($red2-$red1)*0.30)**2 + (($green2-$green1)*0.59)**2 + (($blue2-$blue1)*0.11)**2);
  }

  return $difference;
}

sub get_rgb {
  my $color = shift @_;

  if ($color =~ /#(?<red>[0-9a-f]{2})(?<green>[0-9a-f]{2})(?<blue>[0-9a-f]{2})/i) {
    return hex $+{red}, hex $+{green}, hex $+{blue};
  } else {
    die "ERROR: incorrect format for hex color code: $!";
  }
}

sub get_closest_256_color {
  my ($hex_color, @colors_256) = @_;

  my $min_so_far = hex '0xFFFFFF';
  my $counter = 0;
  my $index_of_min;

  foreach my $color_256 (@colors_256) {
    my $difference = calc_euclidean_distance($hex_color, $color_256);

    if ($difference < $min_so_far) {
      $min_so_far = $difference;
      $index_of_min = $counter;
    }
    $counter += 1;
  }

  # The returned index is the closest 256 color code
  return $index_of_min;
}

=head1 NAME

hex-to-256.pl - convert hex color code to closest 256 color

=head1 DESCRIPTION

B<hex-to-256.pl> converts hex color codes to the closest 256 color.
By default, B<hex-to-256.pl> will use the weighted Euclidean Distance calculation.
If this causes any unexpected/inaccurate results, use the B<--unweighted> option.

=head1 SYNOPSIS

hex-to-256.pl [OPTIONS] HEX_COLOR_CODE

  -u, --unweighted    Use the unweighted Euclidean Distance calculation
  -h, --help          Print this help and exit

For more detailed documentation, run C<perldoc hex-to-256.pl>

=head1 EXAMPLES

Print weighted equivalent 256 color of '#ff3030'

  $ hex-to-256.pl '#ff3030'

Print unweighted equivalent 256 color of '#d4f42b'

  $ hex-to-256.pl --unweighted '#d4f42b'

=cut
