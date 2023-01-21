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

# Ignore git directories from git-annex
my @lossless_files =
  grep { /^$lossless_prefix/ }
  grep { ! /\.git\// }
  File::Find::Rule->file()->in($specified_path);

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
    print "Converting '$file'...\n";
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
