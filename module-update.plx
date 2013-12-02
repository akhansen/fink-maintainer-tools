#!/usr/bin/env perl

use strict;
use Fink;
use Fink::SysState;
use Getopt::Long;

my ($lang,$old_vers,$new_vers);
my $options=GetOptions	(	'lang=s' => \$lang,
							'old=i' =>	\$old_vers,
							'new=i' =>	\$new_vers,
						);
my @supported_lang=qw	(
							oct
							pm
							py
							rb
							r
							dummy
						);

die "Usage:\n\nmodule-update.plx --lang=<oct|pm|py|rb|r> --old=<old value> --new=<new value>\n".
	"\nExample:\n\tmodule-update.plx --lang=pm --old=5123 --new=5124\n" if !($lang && $old_vers && $new_vers);

foreach (@supported_lang) {
	last if $lang eq $_;	
} continue {
	die "$lang isn't a supported option.\n" if $_ eq 'dummy';
}
my $old_mod=$lang.$old_vers;
my $new_mod=$lang.$new_vers;
print " $old_mod -> $new_mod\n";

my $state = Fink::SysState->new();
my @pkg_names = $state->list_packages();

# create list of installed matching packages
my @pkg_filtered;
foreach (@pkg_names) {
	if (m/$old_mod/) {
		push @pkg_filtered, ($_);
	} else {
	}
}
die "There are no currently installed $old_mod packages.\n" if !@pkg_filtered;

my @pkgs_to_update;
chomp(my @full_pkg_list=`fink listpackages`);
# check each of our filtered packages for a matching counterpart:
foreach (@pkg_filtered) {
	my $old_pkg=$_;
	s/$old_mod/$new_mod/;
	my $new_pkg=$_;
	next if $state->installed($new_pkg); # no need to install an already-installed package
	next if !grep(/$new_pkg/, @full_pkg_list); # Can't install a nonexistent package
	push @pkgs_to_update,($new_pkg);
}

print "Installing @pkgs_to_update\n.";
exec "fink install @pkgs_to_update";
