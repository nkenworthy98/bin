#!/usr/bin/perl
# Quickly navigate to various sites using dmenu
# The following sites are supported:
#   nitter
#   libreddit
#   archwiki
#   searx
#
# When dmenu asks you to enter in a username or subreddit, you can enter in
# multiple usernames/subreddits (separated by spaces) and have them open up
# in a browser.
use strict;
use warnings;

my $browser = 'firefox';

my %sites_hash = (
  'nitter' => \&open_nitter_pages,
  'libreddit' => \&open_libreddit_pages,
  'archwiki' => \&open_archwiki_pages,
  'searx' => \&open_searx_pages,
);

my $site_choices_ref = ask_user_for_site(\%sites_hash);

my @urls = ();
foreach my $site_choice (@{$site_choices_ref}) {
  if (exists $sites_hash{$site_choice}) {

    # @urls should be a flat array
    # Without the code below, @urls becomes an array of arrays
    my $urls_ref = $sites_hash{$site_choice}->();
    foreach my $url (@{$urls_ref}) {
      push(@urls, $url);
    }
  }
}

# Firefox is the only browser that I know supports the --new-tab option
# Will open tabs in existing instance of firefox if one is running
if (`pidof '$browser'` && $browser eq 'firefox') {
  @urls = map { "--new-tab '$_'" } @urls;
}

my $urls_str = join(" ", @urls);

if (@urls) {
  exec(qq( $browser $urls_str ));
}

sub ask_user_for_site {
  my ($sites_hash_ref) = @_;

  my @sites = sort keys %{$sites_hash_ref};
  my $site_count = scalar @sites;
  my $printf_format_str = create_printf_format_str($site_count);
  # $site_choices_str can have more than one site if user selects multiple values from dmenu
  # These sites are separated by newlines
  my $site_choices_str = `printf '$printf_format_str' @sites | dmenu -i -l $site_count -p 'Site?'`;

  my @site_choices = split("\n", $site_choices_str);

  return \@site_choices;
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
  my @nitter_usernames = split(' ',`printf '' | dmenu -p 'Nitter Username(s)?'`);
  my @nitter_urls = ();

  foreach my $user (@nitter_usernames) {
    # different nitter instances for different nitter pages
    chomp(my $nitter_base_url = `grni.sh`);
    my $url = "https://$nitter_base_url/$user";

    push(@nitter_urls, $url);
  }

  # User might not type a username, so return homepage
  if (! @nitter_usernames) {
    # grni.sh is a script that returns a random nitter instance
    chomp(my $nitter_home_page = `grni.sh`);
    push(@nitter_urls, $nitter_home_page);
  }

  return \@nitter_urls;
}

sub open_libreddit_pages {
  # Open libreddit home page if a subreddit isn't provided
  my @libreddit_subreddits = split(' ',`printf '' | dmenu -p 'Libreddit Subreddit(s)?'`);
  my @libreddit_urls = ();

  foreach my $subreddit (@libreddit_subreddits) {
    my $url = "https://libredd.it/r/$subreddit/";

    push(@libreddit_urls, $url);
  }

  # return libreddit homepage if user doesn't enter subreddit in dmenu
  if (! @libreddit_subreddits) {
    push(@libreddit_urls, "https://libredd.it");
  }

  return \@libreddit_urls;
}

sub open_archwiki_pages {
  my $archwiki_string = `printf '' | dmenu -p 'ArchWiki Page(s)? (Type ! at beginning for search)'`;
  chomp($archwiki_string);
  my @archwiki_urls = ();

  if (is_archwiki_search($archwiki_string)) {
    push(@archwiki_urls, open_archwiki_search_page($archwiki_string));
  }
  else {
    my $title_pages_ref = open_archwiki_title_pages($archwiki_string);
    @archwiki_urls = @{$title_pages_ref};
  }

  return \@archwiki_urls;
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

 return $url;
}

sub open_archwiki_title_pages {
  my ($archwiki_string) = @_;

  my @archwiki_pages = split(' ', $archwiki_string);
  my @archwiki_urls = ();

  foreach my $page (@archwiki_pages) {
    my $url = "https://wiki.archlinux.org/title/$page?useskinversion=1";
    push(@archwiki_urls, $url);
  }

  return \@archwiki_urls;
}

sub open_searx_pages {
  my $searx_string = `printf '' | dmenu -p 'Searx queries? (Separate searches with '!')'`;
  chomp($searx_string);
  my @urls_searx = ();

  $searx_string =~ s/ /+/g;
  my @searxes = split('!', $searx_string);

  foreach my $search_query (@searxes) {
    my $url = "http://localhost:8888/search?q=$search_query";
    push(@urls_searx, $url);
  }

  return \@urls_searx;
}
