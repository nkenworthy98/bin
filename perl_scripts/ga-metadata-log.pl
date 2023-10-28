#!/usr/bin/perl
# Currently only works when run at root of git annex dir
use strict;
use warnings;
use JSON;
use POSIX qw(strftime);

my @paths;

foreach my $arg (@ARGV) {
    if ($arg) {
        if (-f $arg || -d $arg || -l $arg) {
            push(@paths, $arg);
        }
        else {
            warn "Warning: '$arg' isn't a valid file/path. Ignoring... $!";
        }
    }
}

if (! @paths) {
    # Use current directory if user doesn't provide a file/path
    push(@paths, ".");
}

my @quoted_paths = map { qq("$_") } @paths;
my $quoted_paths_str = join(' ', @quoted_paths);

my @metadata_lines = `git annex metadata --json $quoted_paths_str`;
chomp(@metadata_lines);
my $joined_metadata_lines = join(',', @metadata_lines);

# git-annex doesn't wrap an array of json objects with "[" and "]"
my $metadata_lines = sprintf("[%s]", $joined_metadata_lines);
my $metadata_json = decode_json $metadata_lines;

my %keys_and_files = map { $_->{'key'} => $_->{'file'} }
                     @{$metadata_json};

# Let's say a git annex key is SHA256E-s1234-1234.webm
# The below map will return "*SHA256E-s1234-1234.webm*.met"
my @wildcard_keys = map { qq("*$_*.met") }
                    keys %keys_and_files;

my $wildcard_keys_str = join(' ', @wildcard_keys);

# Running git-log on the git-annex branch with the wildcards only seems to run at the root of
# the git directory
my $git_root = `git rev-parse --show-toplevel`;
chomp($git_root);
chdir($git_root)
    or die "Error: failed to cd to '$git_root' $!";
my $git_log_output = `git log --color=always --stat=150 -p git-annex -- $wildcard_keys_str`;

foreach my $key (keys %keys_and_files) {
    my $file = $keys_and_files{$key};
    $git_log_output =~ s/$key/$file/g;
}

$git_log_output =~ s/(\d+).\d+s/strftime("%F %T", localtime($1))/eg;

open(my $less_pipe, "|-", 'less -R')
    or die "Error when opening pipe to 'less -R' $!";

# Without this binmode, there can be a warning about a wide character when printing
binmode($less_pipe, ':utf8');
print $less_pipe $git_log_output;

close($less_pipe);
