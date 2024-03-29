#!/usr/bin/perl
# Starting from last gem of current set, decrement both the address and the best
# gem address a set number of times
use strict;
use warnings;
use bigint qw(hex);

my $address_input = '';
my $gem_id_input = '';

if (!is_valid_hex($address_input)) {
    die "'$address_input' isn't a valid hex value/address: $!";
}

if (!is_valid_hex($gem_id_input)) {
    die "'$gem_id_input' isn't a valid hex value: $!";
}

my $last_address = hex $address_input;
my $best_gem_id_hex = hex $gem_id_input;
my $gems_to_change = 12;

my $address_step = hex '0x10';
my $gem_step = hex '0x1';

foreach my $mult (0..$gems_to_change) {
    my $text = sprintf "write bytearray %x %x",
        $last_address - ($mult * $address_step),
        $best_gem_id_hex - ($mult * $gem_step);

    system(qq(tmux send-keys '$text' Enter\;))
}

sub is_valid_hex {
    my ($hex_str) = @_;

    return $hex_str =~ m{^0x[0-9a-fA-F]+$};
}
