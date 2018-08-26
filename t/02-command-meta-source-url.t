#! /usr/bin/env perl6

use v6.c;

use App::Assixt::Commands::Meta::SourceUrl;
use App::Assixt::Config;
use App::Assixt::Test;
use Config;
use Dist::Helper::Meta;
use File::Temp;
use Test;

plan 2;

my IO::Path $module = create-test-module("Test::Meta::SourceUrl", tempdir.IO);
my Config $config = get-config(:!user-config).read: %(
	cwd => $module,
);

is get-meta($module.absolute)<source-url>, "Localhost", "Source-url is Localhost";

App::Assixt::Commands::Meta::SourceUrl.run("tyil.nl", :$config);

is get-meta($module.absolute)<source-url>, "tyil.nl", "Source-url got updated";

# vim: ft=perl6 noet
