#!/usr/bin/perl
# This script converts links in your clipboard to their free alternatives
# youtube to invidious
# twitter to nitter
# reddit to teddit
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

my $notification_msg;

if ($link =~ /youtube.com/) {
  $link =~ s/youtube.com/$invidious_instance/;
  system("printf '$link' | xclip -selection c");
  $notification_msg = "YouTube link converted to Invidious link";
  `notify-send -h string:frcolor:#FA0000 "$notification_msg"`;
}

elsif ($link =~ /twitter.com/) {
  $link =~ s/twitter.com/$nitter_instance/;
  system("printf '$link' | xclip -selection c");
  $notification_msg = "Twitter link converted to Nitter link";
  `notify-send -h string:frcolor:#FAFAFA "$notification_msg"`;
}

elsif ($link =~ /reddit.com/) {
  $link =~ s/reddit.com/teddit.net/;
  system("printf '$link' | xclip -selection c");
  $notification_msg = "Reddit link converted to Teddit link";
  `notify-send -h string:frcolor:#FF4500 "$notification_msg"`;
}

elsif ($link =~ /instagram.com/) {
  $link =~ s/instagram.com/$bibliogram_instance/;
  system("printf '$link' | xclip -selection c");
  $notification_msg = "Instagram link converted to Bibliogram link";
  `notify-send -h string:frcolor:#833BB4 "$notification_msg"`;
}

else {
  `notify-send "Link in clipboard was not converted"`;
}
