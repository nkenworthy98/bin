#!/usr/bin/perl
use strict;
use warnings;
use File::Find::Rule;
use IPC::Open2;
use Getopt::Long qw(GetOptions HelpMessage);
use Getopt::Long qw(:config no_ignore_case);

# CLI Flags/Variables
my $type_username_and_password_flag = 0;
my $type_url_flag = 0;
my $copy_url_flag = 0;
my $type_otp_flag = 0;
my $copy_otp_flag = 0;
my $type_password_flag = 0;
my $copy_password_flag = 0;
my $type_username_flag = 0;
my $copy_username_flag = 0;

GetOptions(
    'type-username-and-password|a' => \$type_username_and_password_flag,
    'help|h' => sub { HelpMessage(0) },
    'type-url|l' => \$type_url_flag,
    'copy-url|L' => \$copy_url_flag,
    'type-otp|o' => \$type_otp_flag,
    'copy-otp|O' => \$copy_otp_flag,
    'type-password|p' => \$type_password_flag,
    'copy-password|P' => \$copy_password_flag,
    'type-username|u' => \$type_username_flag,
    'copy-username|U' => \$copy_username_flag,
) or HelpMessage(1);

my $password_store_dir;
if ($ENV{'PASSWORD_STORE_DIR'}) {
    $password_store_dir = "$ENV{'PASSWORD_STORE_DIR'}/";
}
else {
    $password_store_dir = "$ENV{'HOME'}/.password-store/"
}

my @gpg_files = File::Find::Rule->file()
                                ->name('*.gpg')
                                ->in($password_store_dir);

my @pass_entries = map { extract_pass_entry($password_store_dir, $_) } @gpg_files;

my $selection = get_dmenu_selection(\@pass_entries);

my @file_contents = `pass show "$selection"`;
chomp(@file_contents);

my $pass_info_hashref = get_pass_info(\@file_contents, $selection);

if ($type_username_and_password_flag) {
    type_username_and_password($pass_info_hashref);
}
elsif ($type_url_flag) {
    xdotool_type($pass_info_hashref->{'url'});
}
elsif ($type_otp_flag) {
    xdotool_type($pass_info_hashref->{'otp'});
}
elsif ($type_password_flag) {
    xdotool_type($pass_info_hashref->{'password'});
}
elsif ($type_username_flag) {
    xdotool_type($pass_info_hashref->{'username'});
}
elsif ($copy_url_flag) {
    copy_to_clipboard($pass_info_hashref->{'url'});
}
elsif ($copy_otp_flag) {
    system("pass", "otp", "-c", $selection);
}
elsif ($copy_password_flag) {
    system("pass", "-c", $selection);
}
elsif ($copy_username_flag) {
    copy_to_clipboard($pass_info_hashref->{'username'});
}
else {
    system("pass", "-c", $selection);
}

sub type_username_and_password {
    my ($pass_info_hashref) = @_;

    if ($pass_info_hashref->{'username'} && $pass_info_hashref->{'password'}) {
        xdotool_type($pass_info_hashref->{'username'} . "\t" . $pass_info_hashref->{'password'});
    }
    else {
        die "Error: missing username or password from the entry you selected: $!";
    }
}

sub extract_pass_entry {
    my ($password_store, $gpg_file_path) = @_;

    $gpg_file_path =~ s/^$password_store|\.gpg$//g;

    return $gpg_file_path;
}

sub get_dmenu_selection {
    my ($entries_ref) = @_;

    my $dmenu_str = join("\n", @{$entries_ref});

    my $selection;
    my $pid = open2(my $reader, my $writer, "dmenu -p 'Select an entry:' -i -l 5")
        or die "Problem opening pipe to dmenu: $!";
    print $writer $dmenu_str;
    close($writer);

    $selection = <$reader>;
    close($reader);

    unless ($selection) {
        die "No entry selected from dmenu";
    }

    chomp($selection);

    waitpid($pid, 0);

    return $selection;
}

sub get_pass_info {
    my ($contents_ref, $selection) = @_;

    my %pass_info;
    $pass_info{'password'} = $contents_ref->[0];

    foreach my $line (@{$contents_ref}) {
        if ($line =~ /^(?:user.*|login): ?(.*)$/i) {
            $pass_info{'username'} = $1;
        }
        elsif ($line =~ /^url: ?(.*)$/) {
            $pass_info{'url'} = $1;
        }
    }

    # Don't show message about missing OTP secrets
    my $otp_str = `pass otp "$selection" 2>/dev/null`;
    chomp($otp_str);
    $pass_info{'otp'} = $otp_str;

    return \%pass_info;
}

sub xdotool_type {
    my ($type_str) = @_;

    if ($type_str) {
        system("xdotool", "type", "--clearmodifiers", $type_str);
    }
    else {
        die "Error: unable to type the option you selected: $!";
    }
}

sub copy_to_clipboard {
    my ($copy_str) = @_;

    my $current_clipboard = `xclip -o`;
    pipe_to_xclip($copy_str);

    my $pid = fork();

    # fork, so the 30 second wait can take place in the background
    if (not $pid) {
        sleep 30;
        # system("killall xclip");
        pipe_to_xclip($current_clipboard);
        exit;
    }

    exit;
}

sub pipe_to_xclip {
    my ($pipe_str) = @_;

    open(my $xclip_pipe, '|-', 'xclip -selection clipboard')
        or die "Error opening xclip pipe";
    print $xclip_pipe $pipe_str;
    close($xclip_pipe)
        or die "Error closing xclip pipe";
}

=head1 NAME

passmenu.pl - dmenu for pass written in perl

=head1 DESCRIPTION

passmenu.pl is an alternative to passmenu with more functionality.
This program has the ability to type usernames, passwords, and otp codes from pass entries.
It can also copy these things to the clipboard.

=head1 SYNOPSIS

passmenu.pl [OPTION]

  -a, --type-username-and-password    Type both username and password
  -h, --help                          Print this help menu and quit
  -l, --type-url                      Type url
  -L, --copy-url                      Copy url to clipboard
  -o, --type-otp                      Type otp code
  -O, --copy-otp                      Copy otp code to clipboard
  -p, --type-password                 Type password
  -P, --copy-password                 Copy password to clipboard
  -u, --type-username                 Type username
  -U, --copy-username                 Copy username to clipboard

For more detailed documentation, run C<perldoc passmenu.pl>

=cut
