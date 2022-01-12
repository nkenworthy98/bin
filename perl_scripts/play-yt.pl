#!/usr/bin/perl
use strict;
use warnings;

my $original_link = $ARGV[0];
my $invidious_instance = `grii.sh`;
chomp($invidious_instance);
my $tmp_format_file = '/tmp/play-yt-formats.txt';

# www seems to cause problems, so remove it
$original_link =~ s/www\.//;

die "Argument must be YouTube link\n" unless $original_link =~ /youtube\.com/;
my $invidious_link = $original_link;
$invidious_link =~ s/youtube\.com/$invidious_instance/;

# write_format_list is slow (because of yt-dlp -F), so fork
my $mpv_status = -1;
my $pid = fork();

# Child
if ($pid == 0) {
  print "Child:\n";
  write_format_list($original_link, $tmp_format_file);
  print "Child process finished\n";
  exit;
}

# Parent
print "Parent:\n";
print "Invidious link: $invidious_link\n";
$mpv_status = system("mpv $invidious_link");
print "Parent process finished\n";

# Only enter if child process finished and mpv didn't run properly
# mpv ran correctly if the status is 0
if (wait() && $mpv_status != 0) {
  print "Entered wait condition\n";
  my @format_list = read_format_list($tmp_format_file);
  my $format_code = get_format_code_dmenu(\@format_list);
  print "Format code: $format_code\n";
  print "Check: $mpv_status\n";

  exec("mpv --ytdl-format=$format_code '$original_link'");
}

sub write_format_list {
  my ($yt_link, $output_file) = @_;

  my @ytdl_formats = `yt-dlp -F "$yt_link"`;

  # Grabs lines that start with a valid format code and lines that don't contain
  # the word only (so both video and audio is included)
  # The lines that are grabbed have their '|' and '~' removed
  my @filtered_formats = map { s/\||~//g; $_ }
                         grep { /\A[0-9]{2,3}/ && ! /only/ } @ytdl_formats;

  # return @filtered_formats;

  open(my $out, '>', $output_file) or die "Error opening $output_file: $!";
  print $out @filtered_formats;
  close($out) or die "Error closing $out: $!";
}

sub read_format_list {
  my ($read_file) = @_;

  my @formats = ();
  open(my $in, '<', $read_file) or die "Error opening $read_file: $!";
  @formats = <$in>;
  close($in) or die "Error closing $in: $!";

  return @formats;
}

sub get_format_code_dmenu {
  my ($formats_ref) = @_;

  my $dmenu_formats = join('', @{$formats_ref});
  my $selection = `printf "$dmenu_formats" | dmenu -p "Format?" -l 5 -i`;

  # The first element of @selection_split is the format code
  my @selection_split = split(/\s+/, $selection);
  my $format_code = $selection_split[0];

  return $format_code;
}
