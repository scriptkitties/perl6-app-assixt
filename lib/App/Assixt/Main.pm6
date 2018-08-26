#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Usage;
use Config;

unit module App::Assixt::Main;

sub MAIN (
	Str:D $command = "help",
	*@args,
	Bool:D :$force = False,
	Bool:D :$user-config = False,
	Bool:D :$verbose = False,
	Str:D :$config-file = "",
	Str:D :$module = $*CWD,
) is export {
	my Config $config = get-config(:$config-file, :$user-config);

	$config<runtime> = %();
	$config<force> = $force;
	$config<verbose> = $verbose;
	$config<config-file> = $config-file;
	$config<cwd> = $module;

	@args = parse-args(@args, :$config);

	my $lib = "App::Assixt::Commands::$command.tclc()";

	note "Using $lib to handle $command" if $config<verbose>;

	try require ::($lib);

	if (::($lib) ~~ Failure) {
		note "Command $command wasn't recognized. Try -h for usage help.";

		note ::($lib).Str if $config<verbose>;

		exit 2;
	}

	::($lib).run(|@args, :$config);

	True;
}

sub parse-args(
	@args,
	Config :$config,
) {
	my @leftovers = ();

	for @args -> $arg {
		if (!$arg.starts-with("--")) {
			@leftovers.push: $arg;

			next;
		}

		my $key = $arg.substr(2);
		my $value = True;

		if ($key.contains("=")) {
			($key, $value) = $key.split("=", 2);

			if ($value.starts-with('"'|"'") && $value.ends-with('"'|"'")) {
				$value .= substr(1, *-1);
			}
		}

		$config<runtime>{$key} = $value;
	}

	return @leftovers;
}

# vim: ft=perl6 noet
