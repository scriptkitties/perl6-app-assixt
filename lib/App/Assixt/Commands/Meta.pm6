#! /usr/bin/env false

use v6.c;

use App::Assixt::Output;
use Config;

unit class App::Assixt::Commands::Meta;

multi method run (
	*@args ($, *@),
	Config:D :$config
) {
	my $type = @args.shift;
	my $formatted-type = $type.split("-", :g)».tclc.join();
	my $lib = "{$?CLASS.^name}::$formatted-type";

	err("debug.require", module => $lib, intent => $type) if $config<verbose>;

	try require ::($lib);

	if (::($lib) ~~ Failure) {
		err("error.subcommand", command => $type, docs => $?CLASS.^name);

		note ::($lib).Str if $config<verbose>;

		return;
	}

	::($lib).run(|@args, :$config);
}

multi method run (
	Config:D :$config,
) {
	err("error.subcommand.missing", command => "meta", docs => $?CLASS.^name);
}

=begin pod

=NAME    App::Assixt::Commands::Meta
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.5.0

=head1 Synopsis

assixt meta <subcommand> <value>

=head2 Subcommands

=defn source-url
Set the module's C<source-url> attribute. This indicates where an end-user will
be able to find the unaltered source code of the module.

=head1 Description

Change a meta attribute of the module, which is stored in the C<META6.json>
file.

=head1 Examples

    assixt meta source-url https://gitlab.com/tyil/perl6-app-assixt

=head1 See also

=item1 C<App::Assixt>

=end pod

# vim: ft=perl6 noet
