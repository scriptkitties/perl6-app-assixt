#! /usr/bin/env false

use v6.c;

use App::Assixt::Config;
use App::Assixt::Input;
use CPAN::Uploader::Tiny;
use Config;

class App::Assixt::Commands::Upload
{
	multi method run(
		IO::Path:D $dist,
		Config:D :$config,
	) {
		$config<runtime><pause-id> //= $config<pause><id> // ask("PAUSE ID", default => $*USER.Str);
		$config<runtime><pause-password> //= $config<pause><password> // password("PAUSE password");

		my Int $tries = 1;

		while ($tries ≤ $config<pause><tries>) {
			CATCH {
				when $_.payload ~~ / ^ "401 Unauthorized" / {
					note q:to/EOF/;
						Your user credentials were incorrect, please re-try entering your credentials. If you
						are sure your credentials are correct, hit the enter key to retry those credentials.
						EOF

					$config<runtime><pause-id> = ask("PAUSE ID", default => $config<runtime><pause-id>);
					$config<runtime><pause-password> = password("PAUSE password") || $config<runtime><pause-password>;
					$tries++;
				}

				when $_.payload ~~ / ^ "409 Conflict" / {
					note q:to/EOF/;
						The distribution you're trying to upload conflicts with an existing file on CPAN. You
						should probably update the version of your module. You can do this with `assixt bump`
						Create a new distribution with `assixt dist` after that, and try to upload the new
						dist.
						EOF

					return;
				}
			}

			say "Attempt #$tries...";

			my CPAN::Uploader::Tiny $uploader .= new(
				user => $config<runtime><pause-id>,
				password => $config<runtime><pause-password>,
				agent => "Assixt/0.5.0",
			);

			if ($uploader.upload($dist.absolute)) {
				# Report success to the user
				say "Uploaded {$dist.basename} to CPAN";

				return;
			}

			$tries++;
		}

		say "Uploading to CPAN failed, gave up after $tries unsuccesful tries.";
	}

	multi method run (
		Str:D $dist,
		Config:D :$config,
	) {
		self.run($dist.IO, :$config);
	}

	multi method run(
		Str @dists,
		Config:D :$config,
	) {
		$config<runtime><pause-id> //= $config<pause><id> // ask("PAUSE ID", default => $*USER.Str);
		$config<runtime><pause-password> //= $config<pause><password> // password("PAUSE password");

		for @dists -> $dist {
			self.run(
				$dist.IO.absolute,
				:$config,
			);
		}
	}
}

=begin pod

=NAME    App::Assixt::Commands::Upload
=AUTHOR  Patrick Spek <p.spek@tyil.work>
=VERSION 0.5.0

=head1 Synopsis

assixt upload <dist> [--pause-id=Str] [--pause-password=Str]

=head1 Description

Upload a module distribution to L<PAUSE|https://pause.perl.org/pause/query>, to
make it available through L<CPAN|https://www.cpan.org/>.  Optionally, the PAUSE
ID and password can be given as command-line options. If they're not given,
they will be prompted for.

The PAUSE ID can also be set using the configuration key C<pause.id>. If this
is set to a non-empty Str, the PAUSE ID from the configuration will be used and
won't be prompted for.

=head1 Examples

    assixt upload $HOME/.local/var/assixt/App-Assixt-0.4.0.tar.gz
    assixt upload App-Assixt-0.4.0.tar.gz --pause-id=tyil --pause-password=nice-try

=head1 See also

=item1 C<App::Assixt>
=item1 C<App::Assixt::Commands::Dist>

=end pod

# vim: ft=perl6 noet
