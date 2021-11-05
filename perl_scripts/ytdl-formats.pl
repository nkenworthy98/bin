#!/usr/bin/perl
# Print all the information that comes
# after the line containing "format code"
# from the "yt-dlp -F" command

# Prints everything starting from the "format code" line
while (<STDIN>) {
  if (/ID  EXT/../EOF/s) {
    push(@filtered_output, $_);
  }
}

# Remove the "ID   EXT" line from the output
shift @filtered_output;
# Remove the line containing all the "--"
shift @filtered_output;

print @filtered_output;
