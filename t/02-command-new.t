#! /usr/bin/env perl6

use v6.c;

use Test;

BEGIN plan :skip-all<set AUTHOR_TESTING=1 to run bin tests> unless %*ENV<AUTHOR_TESTING>;

use App::Assixt::Config;
use App::Assixt::Test;
use Dist::Helper::Meta;
use File::Temp;

plan 6;

my $assixt = $*CWD;
my $root = tempdir;
my %test-meta = %(
	author => "Patrick Spek",
	description => "Just another test module",
	email => "p.spek@tyil.work",
	license => "GPL-3.0",
	perl => "6.c",
	meta-version => 0
);

my $config = get-config(:no-user-config);

subtest "Create a new module", {
	plan 8;

	chdir $root;

	ok run-bin($assixt, «
		new
		"--name=\"Local::Test::Module\""
		"--author=\"%test-meta<author>\""
		"--email=\"%test-meta<email>\""
		--perl=c
		"--description=\"%test-meta<description>\""
		"--license=%test-meta<license>"
	»), "assixt new";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-Module";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.gitignore".IO.e, "Gitignore created";
	ok "$module-root/.gitlab-ci.yml".IO.e, "GitLab CI config created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";
	ok "$module-root/CHANGELOG.md".IO.e, "CHANGELOG created";

	subtest "Verify META6.json", {
		plan 10;

		my %meta = get-meta($module-root);

		is %meta<meta-version>, %test-meta<meta-version>, "meta-version is correct";
		is %meta<perl>, %test-meta<perl>, "perl is correct";
		is %meta<name>, "Local::Test::Module", "name is correct";
		is %meta<description>, %test-meta<description>, "description is correct";
		is %meta<license>, %test-meta<license>, "license is correct";
		is %meta<version>, "0.0.0", "version is correct";
		is %meta<authors>, "{%test-meta<author>} <{%test-meta<email>}>", "author is correct";
		is %meta<resources>.elems, 0, "resources is empty";
		is %meta<provides>.elems, 0, "provides is empty";
		is %meta<depends>.elems, 0, "depends is empty";
	}
};

subtest "Create a new module with force", {
	plan 8;

	chdir $root;

	ok run-bin($assixt, «
		--force
		new
		"--name=\"Local::Test::Module\""
		"--author=\"%test-meta<author>\""
		"--email=%test-meta<email>"
		--perl=d
		--description=Nondescript
		"--license=%test-meta<license>"
	»), "assixt new --force";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-Module";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.gitignore".IO.e, "Gitignore created";
	ok "$module-root/.gitlab-ci.yml".IO.e, "GitLab CI config created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";
	ok "$module-root/CHANGELOG.md".IO.e, "CHANGELOG created";

	subtest "Verify META6.json", {
		plan 10;

		my %meta = get-meta($module-root);

		is %meta<meta-version>, %test-meta<meta-version>, "meta-version is correct";
		is %meta<perl>, "6.d", "perl is correct";
		is %meta<name>, "Local::Test::Module", "name is correct";
		is %meta<description>, "Nondescript", "description is correct";
		is %meta<license>, %test-meta<license>, "license is correct";
		is %meta<version>, "0.0.0", "version is correct";
		is %meta<authors>, "{%test-meta<author>} <{%test-meta<email>}>", "author is correct";
		is %meta<resources>.elems, 0, "resources is empty";
		is %meta<provides>.elems, 0, "provides is empty";
		is %meta<depends>.elems, 0, "depends is empty";
	}
};

subtest "Create a new module without gitignore", {
	plan 7;

	chdir $root;

	ok run-bin($assixt, «
		new
		"--name=\"Local::Test::NoGitModule\""
		"--author=\"%test-meta<author>\""
		"--email=%test-meta<email>"
		--perl=c
		"--description=\"%test-meta<description>\""
		"--license=%test-meta<license>"
		--no-git
	»), "assixt new --no-git";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-NoGitModule";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.gitlab-ci.yml".IO.e, "GitLab CI config created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";
	ok "$module-root/CHANGELOG.md".IO.e, "CHANGELOG created";

	nok "$module-root/.gitignore".IO.e, "Gitignore missing";
};

subtest "Create a new module without Travis info", {
	plan 7;

	chdir $root;

	ok run-bin($assixt, «
		new
		"--name=\"Local::Test::NoTravisModule\""
		"--author=\"%test-meta<author>\""
		"--email=%test-meta<email>"
		--perl=c
		"--description=\"%test-meta<description>\""
		"--license=%test-meta<license>"
		--no-travis
	»), "assixt new --no-travis";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-NoTravisModule";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.gitignore".IO.e, "Gitignore created";
	ok "$module-root/.gitlab-ci.yml".IO.e, "GitLab CI config created";
	ok "$module-root/CHANGELOG.md".IO.e, "CHANGELOG created";

	nok "$module-root/.travis.yml".IO.e, "Travis config missing";
};

subtest "Create a new module without GitLab CI info", {
	plan 7;

	chdir $root;

	ok run-bin($assixt, «
		new
		"--name=\"Local::Test::NoGitLabModule\""
		"--author=\"%test-meta<author>\""
		"--email=%test-meta<email>"
		--perl=c
		"--description=\"%test-meta<description>\""
		"--license=%test-meta<license>"
		--no-gitlab-ci
	»), "assixt new --no-gitlab-ci";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-NoGitLabModule";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.gitignore".IO.e, "Gitignore created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";
	ok "$module-root/CHANGELOG.md".IO.e, "CHANGELOG created";

	nok "$module-root/.gitlab-ci.yml".IO.e, "GitLab CI config missing";
};

subtest "Create a new module without a changelog", {
	plan 7;

	chdir $root;

	ok run-bin($assixt, «
		new
		"--name=\"Local::Test::NoChangelogModule\""
		"--author=\"%test-meta<author>\""
		"--email=%test-meta<email>"
		--perl=c
		"--description=\"%test-meta<description>\""
		"--license=%test-meta<license>"
		--no-changelog
	»), "assixt new --no-changelog";

	my $module-root = "$root/{$config<new-module><dir-prefix>}Local-Test-NoChangelogModule";

	ok $module-root.IO.d, "Module directory created";
	ok "$module-root/.editorconfig".IO.e, "Editorconfig created";
	ok "$module-root/.gitignore".IO.e, "Gitignore created";
	ok "$module-root/.travis.yml".IO.e, "Travis config created";
	ok "$module-root/.gitlab-ci.yml".IO.e, "GitLab CI config created";

	nok "$module-root/CHANGELOG.md".IO.e, "CHANGELOG missing";
};

# vim: ft=perl6 noet
