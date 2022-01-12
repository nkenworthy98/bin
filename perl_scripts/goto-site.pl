#!/usr/bin/perl
# Quickly navigate to various sites using dmenu
# The following sites are supported:
#   nitter
#   teddit
#   archwiki
#   searx
#
# When dmenu asks you to enter in a username or subreddit, you can enter in
# multiple usernames/subreddits (separated by spaces) and have them open up
# in a browser.
use strict;
use warnings;

my $browser = 'firefox';

my @sites_list = (
  'nitter',
  'teddit',
  'archwiki',
  'searx',
);

my $site_choice = ask_user_for_site(@sites_list);

if ($site_choice eq 'nitter') {
  open_nitter_pages();
}
elsif ($site_choice eq 'teddit') {
  open_teddit_pages();
}
elsif ($site_choice eq 'archwiki') {
  open_archwiki_pages();
}
elsif ($site_choice eq 'searx') {
  open_searx_pages();
}

sub ask_user_for_site {
  my @sites = @_;

  my $site_count = @sites;
  my $printf_format_str = create_printf_format_str($site_count);
  my $site_choice = `printf '$printf_format_str' @sites | dmenu -i -l $site_count -p 'Site?'`;
  chomp($site_choice);

  return $site_choice;
}

# Used for the printf shell command
# If I have 2 sites, I want the printf shell command to have:
# '%s\n%s\n' as the formatted string
# For 3 sites, it should be '%s\n%s\n%s\n', and so on
sub create_printf_format_str {
  my $string_count = shift @_;

  my $printf_str = "";
  my $count = 0;
  while ($count < $string_count) {
    $printf_str = $printf_str . '%s\n';
    $count += 1;
  }

  return $printf_str;
}

sub open_nitter_pages {
  # Open nitter home page if a username isn't provided
  my @nitter_usernames = split(' ',`printf '' | dmenu -p 'Nitter Username(s)?'`)
      or open_nitter_homepage();
  my @nitter_urls;

  foreach my $user (@nitter_usernames) {
    chomp(my $nitter_base_url = `grni.sh`);
    my $url = "https://$nitter_base_url/$user";

    push(@nitter_urls, $url);
  }

  exec("$browser", @nitter_urls);
}

sub open_nitter_homepage {
  chomp(my $nitter_home_url = `grni.sh`);
  exec("$browser", "https://$nitter_home_url");
}

sub open_teddit_pages {
  # Open teddit home page if a subreddit isn't provided
  my @teddit_subreddits = split(' ',`printf '' | dmenu -p 'Teddit Subreddit(s)?'`)
      or open_teddit_homepage();
  my $teddit_base_url = 'teddit.net';
  my @teddit_urls;

  foreach my $subreddit (@teddit_subreddits) {
    my $url = "https://$teddit_base_url/r/$subreddit?theme=dark";

    push(@teddit_urls, $url);
  }

  exec("$browser", @teddit_urls);
}

sub open_teddit_homepage {
  exec("$browser", "https://teddit.net?theme=dark");
}

sub open_archwiki_pages {
  my $archwiki_string = `printf '' | dmenu -p 'ArchWiki Page(s)? (Type ! at beginning for search)'`;
  chomp($archwiki_string);

  my @archwiki_urls;

  if (is_archwiki_search($archwiki_string)) {
    open_archwiki_search_page($archwiki_string);
  } else {
    open_archwiki_title_pages($archwiki_string);
  }
}

sub is_archwiki_search {
  my ($archwiki_string) = @_;

  return ($archwiki_string =~ /\A!/);
}

sub open_archwiki_search_page {
  my ($archwiki_string) = @_;

  # Get rid of the '!' in the search query
  $archwiki_string =~ s/\A!//;
  # Replace all spaces with '+', so they can be used in the url
  $archwiki_string =~ s/ /+/g;

  my $url = "https://wiki.archlinux.org/index.php?search=$archwiki_string&title=Special%3ASearch&fulltext=1";

  exec("$browser", $url);
}

sub open_archwiki_title_pages {
  my ($archwiki_string) = @_;

  my @archwiki_pages = split(' ', $archwiki_string);
  my $url;
  my @archwiki_urls;

  foreach my $page (@archwiki_pages) {
    $url = "https://wiki.archlinux.org/title/$page?useskinversion=1";

    push(@archwiki_urls, $url);
  }

  exec("$browser", @archwiki_urls);
}

sub open_searx_pages {
  my $searx_string = `dmenu -p 'Searx queries? (Separate searches with '!')'`;

  $searx_string =~ s/ /+/g;
  my @searxes = split('!', $searx_string);

  my @urls_searx = ();
  foreach my $search_query (@searxes) {
    my $url = "http://localhost:8888/search?q=$search_query";

    push(@urls_searx, $url);
  }

  exec("$browser", @urls_searx);
}
