#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::Meta;
use App::Assixt::Config;
use Test::Output;
use Test;

plan 1;

output-like {
	App::Assixt::Commands::Meta.run(config => get-config(:!user-config));
}, / "check the App::Assixt::Commands::Meta documentation" /, "Reference to the documentation is shown";

# vim: ft=perl6 noet
