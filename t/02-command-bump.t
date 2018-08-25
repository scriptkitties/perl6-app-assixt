#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::New;
use App::Assixt::Commands::Touch::Bin;
use App::Assixt::Commands::Touch::Class;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;

plan 5;

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

ok create-test-module($assixt, "Local::Test::Bump"), "assixt new Local::Test::Bump";

chdir "$root/perl6-Local-Test-Bump";
App::Assixt::Commands::Touch::Bin.run("bin", "test-bin", config => get-config());
App::Assixt::Commands::Touch::Class.run("class", "Local::Test::Bump::Test::Class", config => get-config());

subtest "Bump patch version", {
	plan 7;

	is get-meta()<version>, "0.0.0", "Version is now at 0.0.0";
	is get-meta()<api>, "0", "API is now at 0";
	ok run-bin($assixt, « bump patch --force »), "Bump patch level";
	is get-meta()<version>, "0.0.1", "Version is now at 0.0.1";
	is get-meta()<api>, "0", "API is still at 0";

	# This entails 2 additional tests
	for get-meta()<provides>.values -> $file {
		for $file.IO.lines -> $line {
			next unless $line ~~ / \h* "=VERSION" \s+ (\S+) \s* /;

			is $0, "0.0.1", "Version in $file is now at 0.0.1";
		}
	};
};

subtest "Bump minor version", {
	plan 7;

	is get-meta()<version>, "0.0.1", "Version is now at 0.0.1";
	is get-meta()<api>, "0", "API is now at 0";
	ok run-bin($assixt, « bump minor --force »), "Bump minor level";
	is get-meta()<version>, "0.1.0", "Version is now at 0.1.0";
	is get-meta()<api>, "0", "API is still at 0";

	# This entails 2 additional tests
	for get-meta()<provides>.values -> $file {
		for $file.IO.lines -> $line {
			next unless $line ~~ / \h* "=VERSION" \s+ (\S+) \s* /;

			is $0, "0.1.0", "Version in $file is now at 0.1.0";
		}
	};
};

subtest "Bump major version", {
	plan 7;

	is get-meta()<version>, "0.1.0", "Version is now at 0.1.0";
	is get-meta()<api>, "0", "API is now at 0";
	ok run-bin($assixt, « bump major --force »), "Bump major level";
	is get-meta()<version>, "1.0.0", "Version is now at 1.0.0";
	is get-meta()<api>, "1", "API is now at 1";

	# This entails 2 additional tests
	for get-meta()<provides>.values -> $file {
		for $file.IO.lines -> $line {
			next unless $line ~~ / \h* "=VERSION" \s+ (\S+) \s* /;

			is $0, "1.0.0", "Version in $file is now at 1.0.0";
		}
	};
};

subtest "Bump CHANGELOG versions", {
	plan 3;

	my Config $config = get-config;
	my Str $datestamp = Date.new(now).yyyy-mm-dd;

	$config.read: %(
		force => False,
		runtime => %(
			author => "Patrick Spek",
			email => "p.spek@tyil.work",
			perl => "c",
			description => "Nondescript",
			license => "AGPL-3.0",
		),
	);

	subtest "Patch bump", {
		plan 2;

		$config<runtime><name> = "Local::Test::Bump::Patch";
		chdir $root;
		App::Assixt::Commands::New.run(:$config);
		chdir "$root/perl6-Local-Test-Bump-Patch";
		run-bin($assixt, « bump patch --force »);

		for "CHANGELOG.md".IO.lines -> $line {
			next unless $line ~~ / ^ "## [" ( \S+ ) "] - " ( \S+ ) /;

			is $0, "0.0.1", "Version in CHANGELOG.md is now at 0.0.1";
			is $1, $datestamp, "Datestamp in CHANGELOG.md is correct";
		}
	}

	subtest "Minor bump", {
		plan 2;

		$config<runtime><name> = "Local::Test::Bump::Minor";
		chdir $root;
		App::Assixt::Commands::New.run(:$config);
		chdir "$root/perl6-Local-Test-Bump-Minor";
		run-bin($assixt, « bump minor --force »);

		for "CHANGELOG.md".IO.lines -> $line {
			next unless $line ~~ / ^ "## [" ( \S+ ) "] - " ( \S+ ) /;

			is $0, "0.1.0", "Version in CHANGELOG.md is now at 0.1.0";
			is $1, $datestamp, "Datestamp in CHANGELOG.md is correct";
		}
	}

	subtest "Major bump", {
		plan 2;

		$config<runtime><name> = "Local::Test::Bump::Major";
		chdir $root;
		App::Assixt::Commands::New.run(:$config);
		chdir "$root/perl6-Local-Test-Bump-Major";
		run-bin($assixt, « bump major --force »);

		for "CHANGELOG.md".IO.lines -> $line {
			next unless $line ~~ / ^ "## [" ( \S+ ) "] - " ( \S+ ) /;

			is $0, "1.0.0", "Version in CHANGELOG.md is now at 1.0.0";
			is $1, $datestamp, "Datestamp in CHANGELOG.md is correct";
		}
	}
}

# vim: ft=perl6 noet
