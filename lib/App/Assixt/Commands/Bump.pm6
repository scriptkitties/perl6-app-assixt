#! /usr/bin/env false

use v6.c;

use App::Assixt::Input;
use Config;
use Dist::Helper::Meta;
use Version::Semantic;

my Str @bump-types = (
	"major",
	"minor",
	"patch",
);

# TODO: In case of major bump, also bump the api key in META6.json

class App::Assixt::Commands::Bump
{
	multi method run(
		Str:D $type,
		Config:D :$config,
	) {
		die "Illegal bump type supplied: $type" unless @bump-types ∋ $type.lc;

		my %meta = get-meta;
		my Str $version-string = %meta<version>;

		# Set a starting semantic version number to work with
		$version-string = "0.0.0" if $version-string eq "*";

		my Version::Semantic $version .= new(%meta<version>);

		given $type.lc {
			when "major" { $version.bump-major }
			when "minor" { $version.bump-minor }
			when "patch" { $version.bump-patch }
		}

		%meta<version> = ~$version;
		%meta<api> = ~$version.parts[0];

		put-meta(:%meta);

		# Bump other files
		self!bump-provides($config, ~$version, %meta<provides>.values);
		self!bump-changelog($config, ~$version);

		say "{%meta<name>} bumped to to {%meta<version>}";
	}

	multi method run(
		Config:D :$config,
	) {
		my Int $default-bump = 3;

		# Output the possible bump types
		say "Bump parts";

		for @bump-types.kv -> $i,  $type {
			say "  {$i + 1} - $type";
		};

		# Request user input to select the bump type
		my Int $bump;

		loop {
			my $input = ask("Bump part", ~$default-bump.tc);

			$bump = $input.Int if $input ~~ /^$ | ^\d+$/;
			$bump = $default-bump if $bump == 0;

			$bump--;

			last if $bump < @bump-types.elems;
		}

		self.run(@bump-types[$bump], :$config);
	}

	#| Bump the changelog.
	method !bump-changelog (
		Config:D $config,
		Str:D $version,
	) {
		return if $config<runtime><no-bump-changelog>;

		my IO::Path $changelog = "CHANGELOG.md".IO;

		return unless $changelog.e && $changelog.f;

		my Str $updated-file = "";
		my Str $datestamp = Date.new(now).yyyy-mm-dd;

		for $changelog.lines -> $line {
			given $line {
				when / ^ ( "#"+ \h+ ) "[UNRELEASED]" / {
					$updated-file ~= "{$0}[$version] - $datestamp\n";
				}
				default {
					$updated-file ~= "$line\n";
				}
			}
		}

		$changelog.spurt($updated-file);
	}

	#| Bump the =VERSION blocks in pod sections found in files declared in
	#| META6.json's "provides" key.
	method !bump-provides (
		Config:D $config,
		Str:D $version,
		*@files,
	) {
		return if $config<runtime><no-bump-provides>;

		for @files -> $file {
			my Str $updated-file = "";

			for $file.IO.lines -> $line {
				given $line {
					when / ^ ( \h* "=VERSION" \s+ ) \S+ (.*)/ {
						$updated-file ~= "{$0}{$version}{$1}\n";
					}
					default {
						$updated-file ~= "$line\n";
					}
				}
			}

			spurt($file, $updated-file);
		}
	}
}

=begin pod

=NAME    App::Assixt::Commands::Bump
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.5.0

=head1 Synopsis

assixt bump <major|minor|patch>

=head1 Description

Bump the version number of the module. This will update the C<version> key in
the C<META6.json>, as well as the C<=VERSION> meta blocks in the Perl 6 Pod
sections of the module files.

C<App::Assixt> uses the L<Semantic Versioning|https://semver.org> specification
to handle version numbers in B<all> circumstances.

=head1 Examples

    assixt bump major
    assixt bump minor
    assixt bump patch

=head1 See also

=item1 C<App::Assixt>
=item1 L<Semantic Versioning|https://semver.org>

=end pod

# vim: ft=perl6 noet
