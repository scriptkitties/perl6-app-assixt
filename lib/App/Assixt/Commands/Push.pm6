#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Path;
use Dist::Helper;

unit module App::Assixt::Commands::Push;

multi sub assixt(
	"push",
	Str:D $path,
	Config:D :$config,
) is export {
	say "bump";
	say "dist";
	say "upload";
}

multi sub assixt(
	"push",
	Config:D :$config,
) is export {
	assixt(
		"push",
		".",
		:$config,
	)
}

multi sub assixt(
	"push",
	Str @paths,
	Config:D :$config,
) is export {
	for @paths -> $path {
		assixt("push", $path, :$config)
	}
}
