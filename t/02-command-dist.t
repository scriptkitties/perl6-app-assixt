#! /usr/bin/env perl6

use v6.c;

use Test;
use Test::Output;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Commands::Dist;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use File::Temp;
use File::Which;

plan 7;

skip-rest "'tar' is not available" and exit unless which("tar");

my $assixt = $*CWD;
my $root = tempdir;

chdir $root;

ok create-test-module($assixt, "Local::Test::Dist"), "assixt new Local::Test::Dist";
chdir "$root/perl6-Local-Test-Dist";

subtest "Create dist with normal config", {
	plan 2;

	ok run-bin($assixt, «
		--force
		dist
	»), "assixt dist";

	my $output-dir = get-config(:no-user-config)<assixt><distdir>;

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest "--output-dir overrides config-set output-dir", {
	plan 2;

	my Str $output-dir = "$root/output-alpha";

	ok run-bin($assixt, «
		--force
		dist
		"--output-dir=\"$output-dir\""
	»), "assixt dist --output-dir=$output-dir";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest "--output-dir set to a path with spaces", {
	plan 2;

	my Str $output-dir = "$root/output gamma";

	ok run-bin($assixt, «
		--force
		dist
		"--output-dir=\"$output-dir\""
	»), "assixt dist";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
}

subtest "Dist in other path can be created", {
	plan 2;

	my Str $output-dir = "$root/output-beta";

	chdir $root;

	ok run-bin($assixt, «
		--force
		dist
		perl6-Local-Test-Dist
		"--output-dir=\"$output-dir\""
	»), "cpan dist Local-Test-Dir";

	ok "$output-dir/Local-Test-Dist-0.0.0.tar.gz".IO.e, "Tarball exists";
};

subtest "Dist without a README", {
	plan 1;

	create-test-module($assixt, "Local::Test::Dist::Readme");
	unlink "$root/perl6-Local-Test-Dist-Readme/README.pod6";

    my Config $config = get-config(:no-user-config);

    $config<runtime> = %(
        output-dir => "/dev/null"
    );

	stderr-like {
		App::Assixt::Commands::Dist.run($root.IO.add("perl6-Local-Test-Dist-Readme"), :$config);
	}, /"No usable README file found"/, "Missing README error is shown";
}

subtest "Dist with a README.pod6", {
	plan 3;

	create-test-module($assixt, "Local::Test::Dist::Readme::Pod6");

	my Config $config = get-config(:no-user-config);

	$config.read: %(
		runtime => %(
            output-dir => $root.IO.add("output").absolute,
        ),
    );

    ok App::Assixt::Commands::Dist.run($root.IO.add("perl6-Local-Test-Dist-Readme-Pod6"), :$config), "Dist gets created";
	ok False, "Dist contains the README.md";
	ok False, "README.md is removed from main repo again";
}

# vim: ft=perl6 noet
