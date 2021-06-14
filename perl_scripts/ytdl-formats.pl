#!/usr/bin/perl
# Print all the information that comes
# after the line containing "format code"
# from the "youtube-dl -F" command

# Prints everything starting from the
# "format code" line
while (<STDIN>) {
  if (/format code/../EOF/) {
    push(@filtered_output, $_);
  }
}

# Remove the "format code" line from the output
shift @filtered_output;

print @filtered_output;
