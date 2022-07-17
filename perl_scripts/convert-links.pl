#!/usr/bin/perl
# This script converts links in your clipboard to their free alternatives
# youtube to invidious
# twitter to nitter
# reddit to libreddit
# instagram to bibliogram
use strict;
use warnings;

chomp(my $link = `xclip -selection c -o`);

# Remove www. from all urls in clipboard because it seems to cause issues
# when accessing the alternative sites if www. is still in the url
$link =~ s/www\.//;

# Uses some other scripts to get random instances. If the program doesn't
# work properly, make sure to run "uii.sh" and "uni.sh" to download the
# files that "grii.sh" and "grni.sh" use to get the random instances.
chomp(my $invidious_instance = `grii.sh`);
chomp(my $nitter_instance = `grni.sh`);

# /u at the end is required in order to be brought to the correct page
my $bibliogram_instance = "insta.trom.tf/u";

if ($link =~ /youtube\.com/) {
  $link =~ s/youtube\.com/$invidious_instance/;
  show_notification('YouTube', 'Invidious', '#FA0000');
}

elsif ($link =~ /youtu\.be\/(\w+)/) {
  $link = "https://$invidious_instance/watch?v=$1";
  show_notification('YouTube', 'Invidious', '#FA0000');
}

elsif ($link =~ /twitter\.com/) {
  $link =~ s/twitter\.com/$nitter_instance/;
  show_notification('Twitter', 'Nitter', '#FAFAFA');
}

elsif ($link =~ /reddit\.com/) {
  $link =~ s/reddit\.com/libredd\.it/;
  show_notification('Reddit', 'Libreddit', '#FF4500');
}

elsif ($link =~ /instagram\.com/) {
  $link =~ s/instagram\.com/$bibliogram_instance/;
  show_notification('Instagram', 'Bibliogram', '#833BB4');
}

send_link_to_clipboard($link);

if ($link =~ /\Ahttps?:/ && `pidof firefox`) {
  system("firefox $link");
}

sub show_notification {
  my ($original_site, $new_site, $color_code) = @_;

  my $message = "$original_site link converted to $new_site link";
  `notify-send -h string:frcolor:"$color_code" "$message"`;
}

sub send_link_to_clipboard {
  my ($link) = @_;

  open(my $clipboard, "|-", "xclip -selection c")
      or die "Error opening clipboard $!";
  print $clipboard $link;
  close($clipboard) or die "Error closing $clipboard $!";
}
