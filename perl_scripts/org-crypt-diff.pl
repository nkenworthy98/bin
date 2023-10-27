#!/usr/bin/perl
# Used for org diffs that might contain gpg encrypted blocks created with
# org-crypt
use strict;
use warnings;
use IPC::Open2;

my @org_contents = <<>>;
chomp(@org_contents);

my $joined_org_contents = join("\n", @org_contents);
$joined_org_contents =~ s/^(-----BEGIN PGP MESSAGE-----.*?-----END PGP MESSAGE-----)$/decrypt_block($1)/gems;
print $joined_org_contents, "\n";

sub decrypt_block {
    my ($encrypted_block) = @_;

    my $pid = open2(my $reader, my $writer, "gpg -d 2>/dev/null");
    print $writer $encrypted_block;
    close($writer);
    my @decrypted_block = <$reader>;
    close($reader);

    my $joined_decrypted_block = join('', @decrypted_block);

    return $joined_decrypted_block;
}
