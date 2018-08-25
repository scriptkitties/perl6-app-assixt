#! /usr/bin/env false

use v6.c;

use App::Assixt::Templates;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;

#| Touch meta files. These are files that are related to the module's source
#| code, but not necessarily part of the module in order to use it. Examples of
#| this would include CI configuration files. This can be used to add back
#| default templates that were either removed, or added in C<App::Assixt> after
#| a module was created.
class App::Assixt::Commands::Touch::Meta
{
	multi method run (
		"meta",
		Str:D $file,
		Config:D :$config,
    ) {
		my %files =
			changelog => "changelog.md",
			editorconfig => "editorconfig",
			gitignore => "gitignore",
			gitlab => "gitlab-ci.yml",
			gitlab-ci => "gitlab-ci.yml",
			readme => "readme.pod6",
			travis => "travis.yml",
			travis-ci => "travis.yml",
		;

		my $template = %files{$file};

        die "No such template: $file" unless $template;

		my %meta = get-meta;
		my %context =
			name => %meta<name>,
			author => %meta<authors>.join(", "),
			version => %meta<version>,
			description => %meta<description>,
			indent => $config<style><indent>,
			spaces => $config<style><spaces>,
			directory => $*CWD.basename,
			license => %meta<license>,
        ;

		template($template, template-location($template), context => %context, clobber => $config<force>);

		say "Added $template template";
    }
}

=begin pod

=NAME    App::Assixt::Commands::Touch::Meta
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.5.0

=head1 SEE ALSO

C<assixt>

=end pod

# vim: ft=perl6 noet
