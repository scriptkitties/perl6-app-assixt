#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

unit class App::Assixt::Commands::Touch::Bin;

method run(
	Str:D $provide,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>);
	my $path = $config<cwd>.add("bin").add($provide);

	if ($path.e && !$config<force>) {
		note qq:to/EOF/;
			A file already exists at {$path.absolute}. Remove the file, or run this command
			again with `--force` to ignore the error.
			
			EOF

		return;
	}
	

	mkdir $path.parent;
	
	template("module/bin", $path, context => %(
		perl => %meta<perl>,
		vim => template("vim-line/$config<style><indent>", context => $config<style>).trim-trailing,
		author => %meta<authors>.join(", "),
		version => %meta<version>,
		:$provide,
	));

	# Update META6.json
	%meta<provides>{$provide} = $path.relative($config<cwd>);

	put-meta(%meta, $config<cwd>);

	# Inform the user of success
	say "Added $provide to {%meta<name>}";

	$path;
}
