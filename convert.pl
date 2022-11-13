#!/usr/bin/perl -w

use strict;
use constant BUFSIZE => 42;

my ($infile, $outfile) = @ARGV;

open my $fi, '<', $infile or die;
binmode $fi;

my $buffer = '';
 
while (1) {
    my $bytes_read = sysread $fi, $buffer, BUFSIZE, length($buffer);
    die "Could not read file $infile: $!" if !defined $bytes_read;
    last if $bytes_read <= 0;
}
close $fi;

open my $fo, '>', $outfile or die;

print $fo "mydisk.content = new Uint8Array([";
my @hexadecimals = map { '0x' . unpack "H*", $_ } split //, $buffer;
#print(map { '0x' . unpack 'H*', $_ } split //, $buffer);
print $fo join ", ", @hexadecimals;
print $fo "]);";

close $fo;
