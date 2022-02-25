#!/usr/bin/perl
# Print pixel colors of an image file
use strict;
use warnings;
use Getopt::Long qw(GetOptions HelpMessage);
use Getopt::Long qw(:config bundling);
use Term::ANSIColor qw(colored);

# CLI Flags/Variables
my $sort_order = 'descending';
my $num_of_colors = 20;
my $verbose = 0;
my $quality = 1;

GetOptions(
  'ascending|a' => sub { $sort_order = 'ascending' },
  'descending|d' => sub { $sort_order = 'descending' },
  'number|n=i' => \$num_of_colors,
  'verbose|v' => \$verbose,
  'quality|q+' => \$quality,
  'help|h' => sub { HelpMessage(0) },
) or HelpMessage(1);

my $image = $ARGV[0];

unless ($image) {
  die "No image file provided";
}

# Resizing to 500x (default) seems to be a good trade off between how quickly
# the image is processed and the accuracy of color values that are grabbed
# from the image.
# A user can increase the quality of the resize (and also increase the
# processing time) by passing in more -q flags, which could to lead to more
# accurate pixel colors
my $resize_value = $quality * 500;

# The below command using convert (part of the imagemagick suite) will grab
# information about the image file including the hex color codes of the pixels,
# as well as the number of times those pixels appear in the image
# my @convert_output = `convert '$image' -colors $num_of_colors -depth 8 -format '%c' histogram:info:`;
my @convert_output = `convert '$image' -resize "$resize_value"x\\> -colors $num_of_colors -depth 8 -format '%c' histogram:info:`;

# If @convert_output is empty, that means that the above command failed,
# which is most likely because $image is not an image file
if (! @convert_output) {
  my $die_message = <<"END_DIE_MESSAGE";
Error: 'convert' command failed
Check that 'convert' is on the system (might need to install imagemagick)
Make sure that '$image' is a valid image file
END_DIE_MESSAGE

  die $die_message;
}
chomp(@convert_output);

# Colon and leading tab will cause issues for sorting later, so substitute out
foreach my $line (@convert_output) {
  $line =~ s/://;

  if ($line =~ /\A(?<leading_tab>\s+)/) {
    $line =~ s/$+{leading_tab}//;
  }
}

# Useful for debugging the sort. Prints the order that the lines will be sorted
if ($verbose) {
  my @sort_test_asc = sort { (split(' ', $a))[0] <=> (split(' ', $b))[0] } @convert_output;
  my @sort_test_desc = sort { (split(' ', $b))[0] <=> (split(' ', $a))[0] } @convert_output;

  print "Ascending\n";
  print "$_\n" for @sort_test_asc;
  print "\n";

  print "Descending\n";
  print "$_\n" for @sort_test_desc;
  print "\n";
}

my @extracted_hex_codes = ();

# (split(' ', $a and $b))[0] grabs the column that has the number of times
# each color appeared in the image file.
if ($sort_order eq 'descending') {
  @extracted_hex_codes = map { (/(#[0-9a-f]{6})/i) ? ($1) : () }
                         sort { (split(' ', $b))[0] <=> (split(' ', $a))[0] }
                         @convert_output;
}
elsif ($sort_order eq 'ascending') {
  @extracted_hex_codes = map { (/(#[0-9a-f]{6})/i) ? ($1) : () }
                         sort { (split(' ', $a))[0] <=> (split(' ', $b))[0] }
                         @convert_output;
}

if ($verbose) {
  print "Unsorted convert command output:\n";
  print "$_\n" for @convert_output;
  print "\n";
  print "Extracted hex codes:\n";
  print "$_\n" for @extracted_hex_codes;
  print "\n";
}

my $output_buffer = '';
foreach my $color (@extracted_hex_codes) {
  my $color_256 = `hex-to-256.pl --unweighted '$color'`;
  chomp($color_256);

  my ($red, $green, $blue) = get_true_color_equivalents($color);
  my $color_str = 'r' . $red . 'g' . $green . 'b' . $blue;

  $output_buffer .= "$color -> ";
  # Print hex color codes in true color (assuming terminal supports it)
  $output_buffer .= colored($color, 'on_' . $color_str) . ' ';
  $output_buffer .= colored($color, $color_str) . ' -> ';
  # Print equivalent 256 colors
  $output_buffer .= colored($color_256, 'on_ansi' . $color_256) . ' ';
  $output_buffer .= colored($color_256, 'ansi' . $color_256) . "\n";
}

print $output_buffer;

sub get_true_color_equivalents {
  my ($hex_code) = @_;

  $hex_code =~ s/#//;
  my @hex_bytes = ($hex_code =~ /[0-9a-f]{2}/gi);

  # decimal (base 10) equivalents
  my @dec_equivalents = map { get_dec_equivalent($_) } @hex_bytes;

  my $red = $dec_equivalents[0];
  my $green = $dec_equivalents[1];
  my $blue = $dec_equivalents[2];

  return $red, $green, $blue;
}

sub get_dec_equivalent {
  my ($hex_byte) = @_;

  # convert to decimal value and make sure that there are always 3 digits
  my $dec = sprintf "%03d", hex $hex_byte;

  return $dec;
}

=head1 NAME

pixel.pl - print the pixel colors of an image file and the corresponding 256 color

=head1 SYNOPSIS

pixel.pl [OPTIONS...] IMAGE_FILE

  -a, --ascending      Print color codes in order from least to most frequent
  -d, --descending     Print color codes in order from most to least frequent (default)
  -n, --number NUMBER  Output at most NUMBER of color codes (default: 20)
  -v, --verbose        Print extra information about what is being parsed
  -q, --quality        Increase quality of image by 500 pixels
                         (increased with each -q flag)
  -h, --help           Print this help and exit

For more detailed documentation and examples, run C<perldoc pixel.pl>

=head1 EXAMPLES

Print 20 color codes of an image from most to least frequent (default)

  $ pixel.pl image.jpg

Print color codes of an image from least to most frequent

  $ pixel.pl -a image.jpg

Print 35 color codes of an image from least to most frequent

  $ pixel.pl -an 35 image.jpg

Print color codes of a higher quality version of the image if possible.
This will slow down the processing of the image with the potential to increase the accuracy of the pixel color codes.
Also, it will only use the increased resolution if it is less than the quality of the original image.

  # More quality (-q) flags being passed could result in more accurate color codes
  $ pixel.pl -q image.jpg
  $ pixel.pl -qq image.jpg
  $ pixel.pl -qqq image.jpg

=cut
