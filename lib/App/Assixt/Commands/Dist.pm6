#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper;
use File::Which;
use IO::Path::Dirstack;

unit class App::Assixt::Commands::Dist;

multi method run (
	IO::Path:D $path,
	Config:D :$config,
) {
	if (!$path.add("./META6.json").IO.e) {
		note qq:to/EOF/;
			No META6.json in {$path.absolute}. Are you sure you're in a
			Perl 6 module directory? You can also specify a path to a Perl
			6 module directory as an argument to make a distribution of
			that module.

			EOF

		return;
	}

	if (!which("tar")) {
		note q:to/EOF/;
			'tar' is not available on this system. Please use your
			operating system's package manager to install it.
			EOF

		return;
	}

	my %meta = get-meta($path.absolute);

	# Check for required META6.json elements
	if (!%meta<source-url> && !$config<force>) {
		note q:to/EOF/;
			The `source-url` is missing. Either set it using
			`assixt meta source-url <url>`, or use `--force` to ignore this error.
			EOF

		return;
	}

	my Str $fqdn = get-dist-fqdn(%meta);
	my Str $basename = $*CWD.IO.basename;
	my Str $transform = "s/^\./{$fqdn}/";
	my IO::Path $output = "{$config<runtime><output-dir> // $config<assixt><distdir>}/$fqdn.tar.gz".IO;

	# Ensure output directory exists
	mkdir $output.parent;

	if ($output.e && !$config<force>) {
		note qq:to/EOF/;
			A distribution tarball already exists at {$output.absolute}.
			Remove this file or run this command again with `--force` to
			ignore this error.
			EOF

		return;
	}

	my Str $readme = self.make-readme($path, :$config);

	# Ensure there's a viable README file
	if (!self.ensure-readme($path, :$config) && !$config<force>) {
		note q:to/EOF/;
			No usable README file found! Add a README.pod6 using `assixt
			touch meta readme.pod6`, or use --force to skip this check.
			EOF

		return;
	}

	# Set tar flags based on version
	my $tar-version-cmd = run « tar --version », :out;
	my Version $tar-version .= new: $tar-version-cmd.out.lines[0].split(" ")[*-1];

	my Str @tar-flags = «
		--transform "$transform"
		--exclude-vcs
		--exclude=.[^/]*
		--owner=0
		--group=0
		--numeric-owner
	»;

	my Version $version-exclude-vcs-ignores = v1.27.1+;

	@tar-flags.push: "--exclude-vcs-ignores" if $tar-version ~~ $version-exclude-vcs-ignores;

	if ($config<verbose>) {
		say "tar czf {$output.absolute} {@tar-flags} .";
	}

	pushd($path);
	run « tar czf "{$output.absolute}" {@tar-flags} .», :err;
	popd;

	# Remove the generated README, if any.
	unlink $readme if $readme;

	say "Created {$output.absolute}";

	if ($config<verbose>) {
		my $list = run « tar tf "{$output.absolute}" », :out;

		for $list.out.lines -> $line {
			say "  {$line}";
		}
	}

	$output;
}

multi method run (
	Str:D $path,
	Config:D :$config,
) {
	self.run($path.IO, :$config);
}

multi method run (
	Config:D :$config,
) {
	self.run(
		".",
		:$config,
	)
}

multi method run (
	@paths,
	Config:D :$config,
) {
	for @paths -> $path {
		self.run(
			"dist",
			$path,
			:$config,
		);
	}
}

#| Make a README file, if no acceptable format exists yet. If a README has
#| been made, the absolute path to the README will be returned. An empty
#| Str will be returned if nothing was done.
method make-readme (
	IO::Path:D $path,
	Config:D :$config,
	--> Str
) {
	return "" if "$path/README.md".IO.e;
	return "" if "$path/README".IO.e;

	my %meta = get-meta($path.absolute);

	my @pods = «
		"$path/README.pod6"
		"$path/README.pod"
	»;

	@pods.push: %meta<provides>{%meta<name>} if %meta<provides>{%meta<name>}:exists;

	my Str $main-module = "$path/lib/" ~ %meta<name>.split("::").join("/");

	@pods.push: "$main-module.pm6";
	@pods.push: "$main-module.pm";
	@pods.push: "$main-module.pod6";
	@pods.push: "$main-module.pod";

	for @pods -> $pod {
		next unless $pod.IO.e;

		my Proc $converter = run << "$*EXECUTABLE" --doc=Markdown "$pod" >>, :out, :err;
		my Int $exit-code = $converter.exitcode;

		$exit-code = $converter.exitcode while $exit-code < 0;

		if ($exit-code) {
			note q:to/EOF/;
				You need Pod::To::Markdown to use Pod 6 documents as
				README. You can install this with zef: `zef install
				Pod::To::Markdown`.
				EOF

			if ($config<verbose>) {
				$converter.err.slurp.note;
			}

			next;
		}

		spurt($path.add("README.md"), $converter.out.slurp(:close));

		return $path.add("README.md").absolute;
	}

	"";
}

#| Ensure a README in an acceptable format is available.
method ensure-readme (
	IO::Path:D $path,
	Config:D :$config,
	--> Bool
) {
	return True if "$path/README.md".IO.e;
	return True if "$path/README".IO.e;

	False;
}

=begin pod

=NAME    App::Assixt::Commands::Dist
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.5.0

=head1 Synopsis

assixt dist [--output-dir=Str]

=head1 Description

Create a distribution tarball of a module. The resulting tarball will be saved
in the location specified by the C<assixt.distdir> configuration key.
Optionally, C<--output-dir> can be given a path to store the distribution in,
which will take precedence over the C<assixt.distdir> value.

=head1 Examples

    assixt dist
    assixt dist --output-dir=/tmp

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Config>

=end pod

# vim: ft=perl6 noet
