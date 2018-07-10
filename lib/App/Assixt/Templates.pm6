#! /usr/bin/env false

use v6.c;

unit module App::Assixt::Templates;

#| Figure out where to store a given file, based on the template name used by
#| C<Dist::Helper>.
sub template-location (
	Str:D $template,
	--> Str
) is export {
	given $template {
		when "changelog.md"  { return "CHANGELOG.md" }
		when "editorconfig"  { return ".$template"   }
		when "gitignore"     { return ".$template"   }
		when "gitlab-ci.yml" { return ".$template"   }
		when "readme.pod6"   { return "README.pod6"  }
		default              { return $template      }
	}
}

=begin pod

=NAME    App::Assixt::Templates
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.4.0

=head1 DESCRIPTION

This unit provides subs to deal with the templates provided by C<Dist::Helper>.

=head1 SEE ALSO

=item1 C<Dist::Helper>
=item1 C<App::Assixt>

=end pod

# vim: ft=perl6 noet
