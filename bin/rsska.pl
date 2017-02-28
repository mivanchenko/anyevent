#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use AnyEvent;
use AnyEvent::HTTP;

my @urls = qw(
	http://wz.lviv.ua/interview/192226-pavlo-hrytsenko-mova-tse-te-shcho-viazhe-pokolinnia-z-pokolinniam-viazhe-terytorii
);

my $count = 0;
my $max   = 3;

my $dest_file = 'news1.html';

my $cv = AnyEvent->condvar;

for ( 1 .. $max ) {
	download();
}

$cv->recv;

sub download {
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
		open my $fh, '>', $dest_file;
		print $fh $html;
		close $fh;

		$count--;
		$cv->end;

		say "Total workers: [$count]";
		download();
	};
	return 1;
}

