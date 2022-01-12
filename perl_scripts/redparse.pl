#!/usr/bin/perl
# Quick and dirty parser for reddio, a reddit CLI client
use strict;
use warnings;
use Data::Dumper;

my @reddio_buffer = <STDIN>;

my @filtered = remove_empty_lines(\@reddio_buffer);

my @grouped = group_lines(\@filtered, 3);

my @content = parse_buffer(\@grouped);

foreach my $hash_ref (@content) {
  print "$hash_ref->{'title'} -- $hash_ref->{'id'}\n";
}

sub remove_empty_lines {
  my ($buffer_ref) = @_;

  my @filtered_output = ();

  foreach my $line (@{$buffer_ref}) {
    unless ($line =~ /\A\Z/) {
      chomp($line);
      push(@filtered_output, $line);
    }
  }

  return @filtered_output;
}

sub group_lines {
  my ($buffer_ref, $lines_per_block) = @_;

  my @grouped_lines = ();
  my @block = ();

  foreach my $line (@{$buffer_ref}) {

    push(@block, $line);

    if ($#block == $lines_per_block - 1) {
      push(@grouped_lines, join(' ', @block));
      @block = ();
    }
  }

  return @grouped_lines;
}

sub parse_buffer {
  my ($buffer_ref) = @_;

  my @array_of_posts = ();
  my %post_details = ();

  foreach (@{$buffer_ref}) {
    if (/
        (?<upvotes>[\d-]+)\s
        (?<title>\S.*\S)\s\(.*?\)\s
        (?<url>https?:\/\/.*?|\/r\/.*?)\s
        (?<comment_count>\d+)\scomments?.*\son\s
        (?<subreddit>r\/[\w_]+)\s
        (?<id>t[0-9]_\w+)
        /x) {

        %post_details = (
          upvotes => $+{upvotes},
          title => $+{title},
          url => $+{url},
          comment_count => $+{comment_count},
          subreddit => $+{subreddit},
          id => $+{id}
        );

        push(@array_of_posts, { %post_details });
    }
    else {
      print "PROBLEM\n";
    }
  }

  return @array_of_posts;
}
