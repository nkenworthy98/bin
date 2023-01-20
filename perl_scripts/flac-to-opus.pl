#!/usr/bin/perl
use strict;
use warnings;
use File::Find::Rule;
use File::Copy;
use File::Spec;
use File::Path;
use Cwd;
use Getopt::Long qw(GetOptions HelpMessage);


my $music_prefix = "$ENV{'HOME'}/.Music";
my $lossless_prefix = "$music_prefix/lossless";
my $lossy_prefix = "$music_prefix/lossy";

my $relative_path = $ARGV[0];
my $specified_path = Cwd::abs_path($relative_path);
# print "relative: $relative_path\n";

#if ($relative_path !~ $lossless_prefix) {
#if (! -d "$lossless_prefix/$relative_path") {
#die "Error: '$lossless_prefix/$relative_path' is not a valid path: $!";
#}

# print "$lossless_prefix/jazz/Art Tatum/\n";

# Ignore git directories from git-annex
my @lossless_files =
  grep { /^$lossless_prefix/ }
  grep { ! /\.git\// }
  File::Find::Rule->file()->in($specified_path);
  # File::Find::Rule->file()->in($lossless_prefix . "/jazz/Art Tatum");
  # File::Find::Rule->file()->name()->in($lossless_prefix);
  # File::Find::Rule->file()->name('*.flac')->in($lossless_prefix);

# print "$_\n" for @lossless_files;

foreach my $file (@lossless_files) {

  my $lossy_file = lossy_equivalent($file);
  my $lossy_opus_file = opus_equivalent($lossy_file);

  if (-f $lossy_file || -f $lossy_opus_file) {
    print "'$file' already has lossy equivalent. Skipping...\n";
    next;
  }

  my ($vol, $parsed_dir, $parsed_file) = File::Spec->splitpath($lossy_file);

  if (! -d $parsed_dir) {
      mkpath($parsed_dir);
  }

  if (is_flac($file)) {
    # my $converted_filename = $lossy_file;

    # Copy so the substitution doesn't change the $file variable
    print "Converting '$file'...\n";
    # $converted_filename =~ s/\.flac$/\.opus/g;
    $parsed_file =~ s/\.flac$/\.opus/;

    system("opusenc", $file, "$parsed_dir/$parsed_file");
  }
  else {
    print "Copying non-flac file '$file' to '$lossy_file'...";
    copy($file, $lossy_file);
    print "done\n";
  }

}

sub is_flac {
  my ($filename) = @_;

  return $filename =~ /\.flac$/;
}

sub lossy_equivalent {
  my ($filename) = @_;

  return $filename =~ s/lossless/lossy/r;
}

sub opus_equivalent {
  my ($filename) = @_;

  return $filename =~ s/\.flac$/\.opus/r;
}
