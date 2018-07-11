#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Depend;
use App::Assixt::Config;
use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

plan 2;

my $config = get-config;
$config.set("runtime.no-install", True);

subtest "Remove single dependency", {
	plan 6;

	chdir $root;
	ok create-test-module($assixt, "Local::Test::Undepend::Single"), "assixt new Local::Test::Undepend::Single";
	chdir "$root/perl6-Local-Test-Undepend-Single";
	App::Assixt::Commands::Depend.run("Config:api<0>:ver<1.3.5+>", "Test", "Test::META", :$config);

	my %meta = get-meta;

	is %meta<depends>.elems, 3, "Module has 3 dependencies";
	ok %meta<depends> (cont) "Config:api<0>:ver<1.3.5+>", "Config is included in depends";
    ok run-bin($assixt, « undepend Config »), "assixt undepend Config";

	%meta = get-meta;

	ok %meta<depends> !(cont) "Config:api<0>:ver<1.3.5+>", "Config is no longer included in depends";
	is %meta<depends>.elems, 2, "Module has 2 dependencies";
}

subtest "Remove multiple dependencies", {
	plan 6;

	chdir $root;
	ok create-test-module($assixt, "Local::Test::Undepend::Multiple"), "assixt new Local::Test::Undepend::Multiple";
	chdir "$root/perl6-Local-Test-Undepend-Multiple";
	App::Assixt::Commands::Depend.run("Config:api<0>:ver<1.3.5+>", "Test", "Test::META", :$config);

	my %meta = get-meta;

	is %meta<depends>.elems, 3, "Module has 3 dependencies";
	ok %meta<depends> (cont) "Test", "Test is included in depends";
	ok %meta<depends> (cont) "Test::META", "Test::META is included in depends";
	ok run-bin($assixt, « undepend Test "Test::META" »), "assixt undepend Test Test::META";

	%meta = get-meta;

	is %meta<depends>.elems, 1, "Module has 1 dependency";
}

# vim: ft=perl6 noet
