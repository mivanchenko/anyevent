#!/usr/bin/env perl

# time ./limit.pl -3

use strict;
use warnings;
use 5.010;

use AnyEvent;
use AnyEvent::HTTP;

my @urls = qw(
	https://perlmaven.com/
	https://cn.perlmaven.com/
	https://br.perlmaven.com/
	https://tw.perlmaven.com/
	https://es.perlmaven.com/
	https://it.perlmaven.com/
	https://ko.perlmaven.com/
	https://he.perlmaven.com/
	https://te.perlmaven.com/
	https://ru.perlmaven.com/
	https://ro.perlmaven.com/
	https://fr.perlmaven.com/
	https://de.perlmaven.com/
	https://id.perlmaven.com/
);

my $cv = AnyEvent->condvar;

my $count = 0;
my $max   = 3;

for ( 1 .. $max ) {
	send_url();
}

$cv->recv;

sub send_url {
	return if $count >= $max;

	my $url = shift @urls;
	return unless $url;

	$count++;
	say "Starting a worker for [$url]";
	say "Total workers: [$count]";

	$cv->begin;

	http_get $url, sub {
		my ($html) = @_;
		say "Received [$url]: " . length $html;

		$count--;
		$cv->end;

		say "Total workers: [$count]";
		send_url();
	};
	return 1;
}

