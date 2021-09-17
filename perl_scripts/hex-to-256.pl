#!/usr/bin/perl
use strict;
use warnings;

# TODO: implement a way to pass this value in later
my $original_color = '#8dbf01';

chomp(my @color_list = <<>>);

# Ignore comment on first line of the text file
shift @color_list;

my $min_so_far = hex 0xFFFFFF;
my $index_of_min;
my $counter = 0;

foreach my $line (@color_list) {
  my $difference = calc_euclidean_distance($original_color, $line);
  print "Current difference: $difference\n";

  if ($difference < $min_so_far) {
    $min_so_far = $difference;
    $index_of_min = $counter;
  }
  $counter += 1;
}

print "Here's the minimum: $min_so_far\n";
print "Here's the index of min: $index_of_min\n";

sub calc_euclidean_distance {
  my ($color1, $color2) = @_;

  my ($red1, $green1, $blue1) = get_rgb($color1);
  my ($red2, $green2, $blue2) = get_rgb($color2);

  # This uses weighted values and should, in theory, result in values closer to human perception
  my $difference = sqrt((($red2-$red1)*0.30)**2 + (($green2-$green1)*0.59)**2 + (($blue2-$blue1)*0.11)**2);

  # This is the unweighted calculation
  # my $difference = sqrt(($red2-$red1)**2 + ($green2-$green1)**2 + ($blue2-$blue1)**2);

  return $difference;
}

sub get_rgb {
  my $color = shift @_;

  if ($color =~ /#(?<red>[0-9a-f]{2})(?<green>[0-9a-f]{2})(?<blue>[0-9a-f]{2})/i) {
    return hex $+{red}, hex $+{green}, hex $+{blue};
  } else {
    die "ERROR: incorrect format for RGB color: $!";
  }
}
