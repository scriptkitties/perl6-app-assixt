#! /usr/bin/env false

use v6.c;

use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

unit class App::Assixt::Commands::Touch::Test;

method run (
	Str:D $test,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>);
	my $path = $config<cwd>.add("t").add($test).extension("t", :0parts);

	if ($path.e) {
		note qq:to/EOF/;
			A file already exists at {$path.absolute}. Remove it, or run this
			command again with `--force` to ignore this error.
			EOF

		return;
	}

	my %context = %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
	);

	template("module/test", $path, :%context);

	# Inform the user of success
	say "Added test $test to {%meta<name>}";

	$path;
}
