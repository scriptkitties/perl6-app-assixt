#! /usr/bin/env false

use v6.c;

use Config;
use App::Assixt::Input;
use Dist::Helper::Meta;
use SemVer;

my Str @bump-types = (
	"major",
	"minor",
	"patch",
);

class App::Assixt::Commands::Bump
{
	multi method run(
		Str:D $type,
		Config:D :$config,
	) {
		die "Illegal bump type supplied: $type" unless @bump-types ∋ $type.lc;

		my %meta = get-meta;

		# Update the version accordingly
		my SemVer $version .= new(%meta<version>);

		given $type.lc {
			when "major" { $version.bump-major }
			when "minor" { $version.bump-minor }
			when "patch" { $version.bump-patch }
		}

		%meta<version> = ~$version;

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
