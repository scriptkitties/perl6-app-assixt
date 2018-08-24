#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

plan 3;

ok create-test-module($assixt, "Local::Test::Touch::Meta"), "assixt new Local::Test::Touch::Meta";
chdir "$root/perl6-Local-Test-Touch-Meta";

# Remove some default files, as this test is going to re-create them with the meta command.
unlink ".gitlab-ci.yml";

subtest "Create clean README", {
	plan 2;

	unlink "README.pod6"; # Remove default README.pod6

	ok run-bin($assixt, « touch meta readme »), "assixt touch meta readme";
	ok "README.pod6".IO.e && "README.pod6".IO.f, "README.pod6 created";
}

subtest "Create clean gitlab-ci configuration", {
	plan 2;

	ok run-bin($assixt, « touch meta gitlab »), "assixt touch meta gitlab";
	ok ".gitlab-ci.yml".IO.e && ".gitlab-ci.yml".IO.f, ".gitlab-ci.yml created";
}

# vim: ft=perl6 noet
