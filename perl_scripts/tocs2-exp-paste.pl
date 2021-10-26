#!/usr/bin/perl
use strict;
use warnings;

my @file_contents = `cat /tmp/tocs2-exp.txt`;

# print @file_contents;

my @text_to_paste;
foreach my $line (@file_contents) {
  # Remove newline characters from each line
  $line =~ s/\n//;

  # Remove whitespace at the beginning of lines
  if ($line =~ /\A(?<spaces>\s+)\S/) {
    $line =~ s/$+{spaces}//;
  }

  # Push lines that begin with a non-whitespace character and aren't
  # already in the text_to_paste array
  if ($line =~ /\A\S/ and !grep ( /\A$line\Z/, @text_to_paste )) {
    print "Line being added: ##$line##\n";
    push(@text_to_paste, $line);
  }
}

# print uniq(@text_to_paste);
# print @text_to_paste;

my $num_items_in_clipboard = @text_to_paste;

my $counter = 0;
while ($counter < $num_items_in_clipboard) {
  # Without verbose in the xclip command, program won't wait for each paste event
  system("printf '%s' '$text_to_paste[$counter]' | xclip -loops 1 -verbose -selection c");

  $counter += 1;
}
