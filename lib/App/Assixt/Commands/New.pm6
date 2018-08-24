#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use Config;
use Dist::Helper::Meta;
use Dist::Helper::Template;
use File::Directory::Tree;
use File::Which;
use Hash::Merge;

class App::Assixt::Commands::New
{
	method run(
		Config:D :$config,
	) {
		$config<runtime><name> //= ask("Module name");

		my IO::Path $dir;

		# Make sure the directory path isn't already in use
		CHECKPATH: loop {
            # Get the full path
			$dir .= new($config.get("new-module.dir-prefix") ~ $config<runtime><name>.subst("::", "-", :g));

			# No need to check anything if --force is supplied
			last if $config<force>;

            # Make sure it isn't already taken on the local system
            if ($dir.e) {
                note "{~$dir} is not empty! Use a different module name or remove the directory first.";

				$config<runtime><name> = ask("Module name", $config<runtime><name>);

                redo CHECKPATH;
            }

			# If we can reach this, it should be all right
			last;
		}

		$config<runtime><author> //= ask("Your name", $config.get("new-module.author"));
		$config<runtime><email> //= ask("Your email address", $config.get("new-module.email"));
		$config<runtime><perl> //= ask("Perl 6 version", $config.get("new-module.perl"));
		$config<runtime><description> //= ask("Module description", "Nondescript");
		$config<runtime><license> //= ask("License key", $config.get("new-module.license"));

		# Create the initial %meta
		my %meta = merge-hash(new-meta, %(
			api => "0",
			version => "0.0.0",
			perl => "6.$config<runtime><perl>",
			name => $config<runtime><name>,
			description => $config<runtime><description>,
			license => $config<runtime><license>,
			authors => [
				"$config<runtime><author> <$config<runtime><email>>"
			],
		));

		# Create the module skeleton
		mkdir $dir.absolute unless $dir.d;
		chdir $dir;
		mkdir "bin" unless $config<force> && "bin".IO.d;
		mkdir "lib" unless $config<force> && "lib".IO.d;
		mkdir "resources" unless $config<force> && "resources".IO.d;
		mkdir "t" unless $config<force> && "t".IO.d;

		template("readme.pod6", "README.pod6", clobber => $config<force>, context => %(
			name => %meta<name>,
				author => %meta<authors>.join(", "),
				version => ~%meta<version>,
				description => %meta<description>,
				license => %meta<license>,
		));

		template("editorconfig", ".editorconfig", context => $config<style>, clobber => $config<force>);
		template("gitignore", ".gitignore", clobber => $config<force>) if $config<external><git> && !$config<runtime><no-git>;
		template("travis.yml", ".travis.yml", clobber => $config<force>) if $config<external><travis> && !$config<runtime><no-travis>;
		template("changelog.md", "CHANGELOG.md", clobber => $config<force>) if !$config<runtime><no-changelog>;

		if ($config<external><gitlab-ci> && !$config<runtime><no-gitlab-ci>) {
			my %context =
				moduleName => $config<runtime><name>,
				dirName => $dir,
			;

			template("gitlab-ci.yml", ".gitlab-ci.yml", :%context, clobber => $config<force>);
		}

		# Write some files
		put-meta(:%meta);

		say "Created new project folder at {".".IO.absolute}";
	}
}
