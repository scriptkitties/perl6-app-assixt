#! /usr/bin/env false

use v6.c;

use App::Assixt::Input;
use Config;
use Dist::Helper::Meta;

unit class App::Assixt::Commands::Meta::SourceUrl;

multi method run (
	Str:D $value,
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>.absolute);

	%meta<source-url> = $value;

	put-meta(:%meta, path => $config<cwd>.absolute);
}

multi method run (
	Config:D :$config,
) {
	my %meta = get-meta($config<cwd>.absolute);

	self.run(
		ask("source-url", %meta<source-url>),
		:$config
	);
}

=begin pod

=NAME    App::Assixt::Commands::Meta::SourceUrl
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.5.0

=head1 Synopsis

assixt meta source-url [value]

=head1 Description

Update the C<source-url> value of a module. If no I<value> is given, it will be
prompted.

=head1 Examples

    assixt meta source-url
    assixt meta source-url https://gitlab.com/tyil/perl6-app-assixt

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Meta>

=end pod

# vim: ft=perl6 noet
