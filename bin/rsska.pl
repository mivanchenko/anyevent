#!/usr/bin/env perl

use strict;
use warnings;
use 5.010;

use AnyEvent;
use AnyEvent::HTTP;

# page 1:
# http://wz.lviv.ua/interview/192226-pavlo-hrytsenko-mova-tse-te-shcho-viazhe-pokolinnia-z-pokolinniam-viazhe-terytorii
# page 2:
# http://glavcom.ua/interviews/direktor-institutu-ukrajinskoji-movi-pavlo-gricenko-movni-kvoti-ce-lyapas-usim-ukrajincyam-402601.html

my @urls = qw(
	http://127.0.0.1:5000?page=1
	http://127.0.0.1:5000?page=2
);

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

		save( $count, $html );

		$count--;
		$cv->end;

		say "Total workers: [$count]";
		download();
	};
	return 1;
}

sub save {
	my ( $count, $html ) = @_;

	my $dest_path = $dest_dir . $count . '.html';
	open my $fh, '>', $dest_path
		or die "Can't write to [$dest_path]";
	print $fh $html;
	close $fh;

	sleep 5;
	say "Saved [$count] " . length $html;
}

