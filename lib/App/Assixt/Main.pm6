#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Usage;
use Config;

unit module App::Assixt::Main;

#| An extensive toolkit for module developers.
sub MAIN (
	#| The command to run. Read App::Assixt for a list of available commands
	#| and their descriptions.
	Str:D $command,

	#| Additional arguments to the command you're running.
	*@args,

	#| Ignores most sanity checks when set to True. Use at your own risk.
	Bool:D :$force = False,

	#| If disabled, do not load custom user configuration. This can be useful
	#| to debug whether an issue is due to your configuration.
	Bool:D :$user-config = True,

	#| Enable additional verbosity. This is usually only useful if you're
	#| debugging an issue.
	Bool:D :$verbose = False,

	#| A path to a configuration file, which will be loaded instead of the
	#| default found at $HOME/.config/assixt.toml.
	Str:D :$config-file = "",

	#| Override the current working directory for assixt. This can be used to
	#| work on modules outside of the current working directory.
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
