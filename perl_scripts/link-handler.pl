#!/usr/bin/perl
# Handle links depending on what their url contains
use strict;
use warnings;

my $original_link = $ARGV[0] or die "Must pass in a link: $!";

if (is_sxiv_link($original_link)) {
  system("notify-send 'Opening link in sxiv...'");
  system("curl -o /tmp/sxivtmpfile '$original_link'");
  system("sxiv -a /tmp/sxivtmpfile");
}

elsif (is_mpv_link($original_link)) {
  system("notify-send 'Opening link in mpv...'");
  if ($original_link =~ /youtube\.com/) {
    system("play-yt.pl '$original_link'");
  }
  else {
    system("mpv '$original_link'");
  }
}

else {
  system("notify-send 'Link copied to clipboard'");
  # Copy link to clipboard
  system("printf '$original_link' | xclip -selection c");

  # Uses my script xcc.sh to clear clipboard after 25 seconds
  sleep 25;
  exec("xcc.sh");
}

sub is_sxiv_link {
  my $link = shift @_;

  return ( $link =~ /\.png\Z/
           || $link =~ /\.jpg\Z/
           || $link =~ /\.gif\Z/ )
}

sub is_mpv_link {
  my $link = shift @_;

  return ( $link =~ /youtube\.com/
           || $link =~ /clips\.twitch\.tv/
           || $link =~ /twitch\.tv/
           || $link =~ /odysee\.com/
           || $link =~ /videos\.lukesmith\.xyz/
           || $link =~ /bitchute\.com/ )
}
