#! /usr/bin/env false

use v6.c;

use Config;
use Dist::Helper::Meta;

unit class App::Assixt::Commands::Touch::Resource;

method run(
	Str:D $resource,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>);
	my IO::Path $resources = $config<cwd>.add("resources");

	mkdir $resources unless $resources.d;

	my IO::Path $path = $resources.add($resource);

	# Check for duplicate entry
	if (%meta<resources> ∋ $path.relative($resources)) {
		note "A $resource already exists in {%meta<name>}";
		return;
	}

	# Create the resource
	my $parent = $path.parent;

	mkdir $parent unless $parent.d;
	spurt($path, "");

	# Add the resource to the META6.json
	%meta<resources>.push: $path.relative($resources);
	put-meta(%meta, $config<cwd>);

	# User-friendly output
	say "Added resource $resource to {%meta<name>}";

	$resource;
}
