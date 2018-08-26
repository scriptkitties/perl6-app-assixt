#! /usr/bin/env false

use v6.c;

use Config;

unit class App::Assixt::Commands::Meta;

multi method run (
	*@args ($, *@),
	Config:D :$config
) {
	my $type = @args.shift;
	my $formatted-type = $type.split("-", :g)».tclc.join();
	my $lib = "App::Assixt::Commands::Meta::$formatted-type";

	note "Using $lib to handle $type" if $config<verbose>;

	try require ::($lib);

	if (::($lib) ~~ Failure) {
		note qq:to/EOF/;
			Unknown subcommand '$type' for `meta`. Read the documentation on
			App::Assixt::Commands::Meta for a list of available subcommands.
			EOF

		note ::($lib).Str if $config<verbose>;

		return;
	}

	::($lib).run(|@args, :$config);
}

multi method run (
	Config:D :$config,
) {
	note q:to/EOF/;
		The 'meta' command requires a specific subcommand to be given. For a list of
		available subcommands, check the App::Assixt::Commands::Meta documentation.
		EOF
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
