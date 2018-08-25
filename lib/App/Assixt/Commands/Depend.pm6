#! /usr/bin/env false

use v6.c;

use Config;
use Dist::Helper::Meta;

class App::Assixt::Commands::Depend
{
	multi method run(
		Str:D $module,
		Config:D :$config!,
	) {
		# Get the meta info
		my %meta = get-meta;

		# Install the new dependency with zef
		unless ($config<runtime><no-install>) {
			my $zef = run « zef --cpan install "$module" »;

			die "Zef failed, bailing" if 0 < $zef.exitcode;
		}

		# Add the new dependency if its not listed yet
		if (%meta<depends> ∌ $module) {
			%meta<depends>.push: $module;
		}

		# Write the new META6.json
		put-meta(:%meta);

		# And finish off with some user friendly feedback
		say "$module has been added as a dependency to {%meta<name>}";
	}

	multi method run(
		*@modules,
		Config:D :$config!,
	) {
		samewith($_, :$config) for @modules;
	}
}

=begin pod

=NAME    App::Assixt::Commands::Depend
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.4.0

=head1 Synopsis

assixt depend <module>

=head1 Description

Add a dependency to a given module. This will add it to the C<dependencies> key
in C<META6.json>. Unless the C<--no-zef> option has been passed, it will also
install the module using C<zef> on the local machine.

=head1 Examples

    assixt depend Config
    assixt depend Pod::To::Pager --no-zef

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Undepend>
=item1 C<zef>
=item1 L<Perl 6 module directory|https://modules.perl6.org>

=end pod

# vim: ft=perl6 noet
