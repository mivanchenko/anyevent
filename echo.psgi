#!/usr/bin/env perl

# https://perlmaven.com/asynchronous-web-server-with-psgi-and-twiggy

# Usage:
# `twiggy echo.psgi`
# access at 127.0.0.1:5000

use strict;
use warnings;

use Plack::Request;

my $app = sub {
	my $env = shift;
	my $html = get_html();

	my $request = Plack::Request->new($env);

	if ( $request->param('field') ) {
		return sub {
			my $response = shift;
			my $t;
			$t = AnyEvent->timer(
				after => 2,
				cb => sub {
					undef $t;
					$html .= 'You said: ' . $request->param('field') . '<br>';
					return $response->(
						[
							'200',
							[ 'Content-Type' => 'text/html' ],
							[ $html ],
						]
					);
				}
			);
		}
	}

	return [
		'200',
		[ 'Content-Type' => 'text/html' ],
		[ $html ],
	];
};

sub get_html {
	return q{
		<form>

		<input name="field">
		<input type="submit" calue="Echo">
		</form>
		<hr>
	}
}
