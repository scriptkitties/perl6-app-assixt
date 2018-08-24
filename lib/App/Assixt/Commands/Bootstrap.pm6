#! /usr/bin/env false

use v6.c;

use Config;

class App::Assixt::Commands::Bootstrap
{
	method run(*@args, Config:D :$config)
	{
		my $type = @args.head.tclc;
		my $lib = "App::Assixt::Commands::Bootstrap::$type";

		try require ::($lib);

		if (::($lib) ~~ Failure) {
			note "No idea what to do with a $type";

			if ($config<verbose>) {
				note ::($lib).Str;
			}

			exit 2;
		}

		::($lib).run(|@args, :$config);
	}
}

=begin pod

=NAME    App::Assixt::Commands::Bootstrap
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.4.0

=head1 Synopsis

assixt bootstrap <target>

=head1 Description

Bootstrapping functionality for C<App::Assixt>. Currently, there's only one
bootstrap command, L<C<config>|App::Assixt::Commands::Bootstrap::Config>.

=head1 Examples

    assixt bootstrap config

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Bootstrap::Config>

=end pod

# vim: ft=perl6 noet
