#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use AnyEvent;
use AnyEvent::HTTP;

# page 1:
# http://wz.lviv.ua/interview/192226-pavlo-hrytsenko-mova-tse-te-shcho-viazhe-pokolinnia-z-pokolinniam-viazhe-terytorii
my @urls = qw(
	http://127.0.0.1:5000?page=1
);

#my @htmls;

my $dest_dir  = '../dest/';

my $cv = AnyEvent->condvar;

my $count = 0;
my $max   = 3;

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

		my $dest_path = $dest_dir . $count . '.html';
		open my $fh, '>', $dest_path
			or die "Can't write to [$dest_path]";
		print $fh $html;
#		push @htmls, $html;
		close $fh;

		$count--;
		$cv->end;

		say "Total workers: [$count]";
		download();
	};
	return 1;
}

