#! /usr/bin/env false

use v6.c;

use Config;

class App::Assixt::Commands::Touch
{
	method run(*@args, Config:D :$config)
	{
		my $type = @args.head.tclc;
		my $lib = "App::Assixt::Commands::Touch::$type";

		try require ::($lib);

		if (::($lib) ~~ Failure) {
			note "No idea how to touch a $type";

			if ($config<verbose>) {
				note ::($lib).Str;
			}

			exit 2;
		}

		::($lib).run(|@args, :$config);
	}
}

=begin pod

=NAME    App::Assixt::Commands::Touch
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.4.0

=head1 Synopsis

assixt touch <type>

=head1 Description

Add a new file to the module. This will generate a skeleton file, and add it to
the module's C<META6.json>.

=head1 Examples

    assixt touch class Local::Test
    assixt touch unit Local::Test::Unit
    assixt touch resource local/resource.txt
    assixt touch test 01-use-ok

=head1 See also

=item1 C<App::Assixt>

=end pod

# vim: ft=perl6 noet
