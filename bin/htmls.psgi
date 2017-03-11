#!/usr/bin/env perl

# https://perlmaven.com/asynchronous-web-server-with-psgi-and-twiggy

# Usage:
# `twiggy htmls.psgi`
# access at 127.0.0.1:5000

use strict;
use warnings;

use Perl6::Slurp;
use Plack::Request;

my $app = sub {
	my $env = shift;

	my $request = Plack::Request->new($env);
	my $page = $request->param('page') || 0;

	if ( $page ) {
		return sub {
			my $response = shift;

			if ( $page !~ /\A\d+\z/ ) {
				return [
					'200',
					[ 'Content-Type' => 'text/html' ],
					[ 'Invalid page number' ],
				];
			}

			my $html = slurp "../src/$page.html";

			return $response->(
				[
					'200',
					[ 'Content-Type' => 'text/html' ],
					[ $html ],
				]
			);
		}
	}

	return [
		'200',
		[ 'Content-Type' => 'text/html' ],
		[ 'Which page do you want?<br /><pre>?page={1,2,3}</pre>' ],
	];
};

