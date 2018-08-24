#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use Config;
use Dist::Helper::Meta;

class App::Assixt::Commands::Bootstrap::Config
{
	multi method run(
		"config",
		Str:D $option,
		Str:D $value,
		Config:D :$config,
	) {
		die "Invalid config option $option" unless $config{$option}:exists;

		given $config{$option} {
			when Bool { $config.set($option, $value.starts-with('y')) }
			when Int  { $config.set($option, +$value)                 }
			when Str  { $config.set($option, ~$value)                 }
		}

		if (!$config<force>) {
			say "$option = {$config{$option}}";
			return unless confirm("Save?");
		}

		put-config(:$config, path => $config<file>);

		say "Configuration updated";
	}

	multi method run(
		"config",
		Str:D $option,
		Config:D :$config,
	) {
		die "Invalid config option $option" unless $config{$option}:exists;

		given $config{$option} {
			when Bool { $config.set($option, confirm($option, $config.get($option, False))) }
			when Int  { $config.set($option, +ask($option, $config.get($option, 0)))        }
			when Str  { $config.set($option, ask($option, $config.get($option, "")))        }
		}

		say "$option = {$config{$option}}";
	}

	multi method run(
		"config",
		Config:D :$config,
	) {
		my @ignored-keys = <
			file
			force
			verbose
			pause.id
		>;

		for $config.keys -> $option {
			next if @ignored-keys (cont) $option;

			self.run(
				"config",
				$option,
				:$config,
			);
		}

		return unless $config<force> || confirm("Save?");

		put-config(:$config, path => $config<file>);

		say "Configuration updated";
	}
}

=begin pod

=head1 Synopsis

assixt bootstrap config

=head1 Description

Walk through the configuration options for C<assixt>, and save the resulting
configuration file.

=head1 Examples

    assixt bootstrap config

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Config>

=end pod

# vim: ft=perl6 noet
