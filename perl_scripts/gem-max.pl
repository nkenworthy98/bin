#!/usr/bin/perl
# quickly assign 0x63 (99) to a range of addresses in scanmem
use strict;
use warnings;
use bigint qw(hex);

# Uncomment to prompt through dmenu
# my $start_address = `printf '' | dmenu -p 'Start address?'`;
# my $end_address = `printf '' | dmenu -p 'End address?'`;

# Comment out if you want to prompt through dmenu
my $start_address = '';
my $end_address = '';

chomp($start_address);
chomp($end_address);

if (!is_valid_address($start_address)) {
    die "'$start_address' isn't a valid address: $!";
}

if (!is_valid_address($end_address)) {
    die "'$end_address' isn't a valid address: $!";
}

my $dec_start_address = hex $start_address;
my $dec_end_address = hex $end_address;
my $hex_line = hex '0x10';

if ($dec_start_address >= $dec_end_address) {
    die "start address ($start_address) must come before end address ($end_address): $!";
}

my $address_diff = $dec_end_address - $dec_start_address;
my $line_diff = $address_diff / $hex_line;

if ($line_diff > 15) {
    die "Number of lines between start address and end address is too large: $!";
}

if (get_last_char($start_address) ne get_last_char($end_address)) {
    die "start address ($start_address) and end address ($end_address) have different last characters: $!";
}

my $hex_line_diff = $address_diff / $hex_line;
foreach my $mult (0..$hex_line_diff) {
    my $text = sprintf "write bytearray %x 63",
        $dec_start_address + ($mult * $hex_line);

    system(qq(tmux send-keys '$text' Enter\;))
}

sub is_valid_address {
    my ($address_str) = @_;

    return $address_str =~ m{^0x[0-9a-fA-F]+$};
}

sub get_last_char {
    my ($str) = @_;

    if ($str =~ /([0-9a-zA-Z])$/) {
        return $1;
    }
}
