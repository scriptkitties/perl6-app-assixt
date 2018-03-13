#! /usr/bin/env false

use v6.c;

unit module App::Assixt::Commands::Help;

sub USAGE is export
{
	%?RESOURCES<docopt.txt>.slurp.say;
}

multi sub MAIN("help") is export
{
	USAGE
}

multi sub MAIN("-h") is export
{
	USAGE
}

multi sub MAIN("--help") is export
{
	USAGE
}
