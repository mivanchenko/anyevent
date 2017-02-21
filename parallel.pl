#!/usr/bin/env perl

# time ./parallel.pl

use strict;
use warnings;
use 5.010;

use AnyEvent;
use AnyEvent::HTTP;

my @urls = qw(
	https://perlmaven.com/
	https://cn.perlmaven.com/
	https://br.perlmaven.com/
);

my $cv = AnyEvent->condvar;

foreach my $url ( @urls ) {
	say "Start $url";
	$cv->begin;

	http_get $url, sub {
		my ($html) = @_;
		say "[$url ]: " . length $html;
		$cv->end;
	};
}

say 'Before the event-loop';
$cv->recv;
say 'Finished';
