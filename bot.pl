#!/usr/bin/perl
# perl bot.pl [options] datafile username
# See the README for more information

use FindBin;
use lib "$FindBin::Bin";

use CoverArtBot;
use LWP::Simple;
use Getopt::Long;
use File::Which;
use XML::Simple qw(:strict);

my $note = "";
my $max = 100;
my $tmpdir = "/tmp/";
my $password = '';
my $remove_note = "";
my $verbose = 0;
my $use_front = 0;
my $image_size = 0;
my $archive_one_image = 0;
my $archive_no_music = 0;
GetOptions('note|n=s' => \$note, 'max|m=i' => \$max, 'tmpdir|t=s' => \$tmpdir, 'password|p=s' => \$password, 'remove-note|r=s' => \$remove_note, 'verbose|v' => \$verbose, 'use-front' => \$use_front, 'image-size|i=i' => \$image_size, 'archive-one-image' => \$archive_one_image, 'archive-no-music' => \$archive_no_music);

my $file = shift @ARGV or die "Must provide a filename";
my $username = shift @ARGV or die "Must provide a username";
my @mbids = ();

open FILE, $file or die "Couldn't open the data file ($file)";
while (<FILE>) {
	chomp;
	my ($mbid, $url, $types, $comment, $rel) = split /\t/;
	push @mbids, { 'mbid' => $mbid, 'url' => $url, 'rel' => $rel, 'types' => $types, 'comment' => $comment };
}
close FILE;

if (!$password) {
	system "stty -echo";
	print "Password for $username: ";
	$password = <>;
	system "stty echo";
	print "\n";
}

my $bot = CoverArtBot->new({username => $username, password => $password, note => $note, remove_note => $remove_note, verbose => $verbose, use_front => $use_front});

my $identify_exe = which('identify');
warn "identify can't be found, install imagemagick for type checking and dimensions in notes" unless $identify_exe;

for my $l (@mbids) {
	unless ($max > 0) {
		print "Reached maximum number of files.\n";
		last;
	}

	$l->{'note_args'} = {url => $l->{'url'}, mbid => $l->{'mbid'}, local => -e $l->{'url'} ? "local" : "remote"};

	my $precheck_ok = $bot->precheck($l);

	if ($precheck_ok) {
		if ($archive_one_image && !archiveorg($l->{'url'})) {
			print STDERR "Too many images or unrecognised files on archive.org. Skipping.\n";
			next;
		}
		if ($archive_no_music && !archiveorg($l->{'url'}, 2)) {
			print STDERR "Too many images, music files or unrecognised files on archive.org. Skipping.\n";
			next;
		}

		my $filename = -e $l->{'url'} ? $l->{'url'} : fetch_image($l->{'url'}, $l->{'mbid'});
		if (!$filename) {
			my $urlname = $l->{'url'};
			print STDERR "Failed to fetch $urlname.\n";
			next;
		}

		if ($identify_exe) {
			my $info = `$identify_exe $filename`;
			my ($xdim, $ydim) = $info =~ / JPEG ([0-9]+)x([0-9]+) /;
			if (!$xdim || !$ydim) {
				print STDERR "Image is not a JPEG, or dimensions can't be found.\n";
				next;
			}
			$l->{'note_args'}->{'x_dim'} = $xdim;
			$l->{'note_args'}->{'y_dim'} = $ydim;
			$l->{'note_args'}->{'identify_output'} = $info;
		}

		my $rv = $bot->run($l, $filename);

		$max -= $rv;
	}

	print "$max more image(s)...\n\n";
}

sub fetch_image {
	my $url = shift;

	return 0 unless $url =~ /\/([^\/]+)$/;
	my $filename = $tmpdir.$1;
	my $r = getstore($url, "$filename");
#	print "$r\n";
	return 0 unless $r == "200";

	my $format = `file "$filename"`;
	print STDERR "Wrong format: $format" unless $format =~ /JPEG image data/;
	return 0 unless $format =~ /JPEG image data/;

	if ($image_size) {
		my $info = `identify "$filename"`;
		if ($info =~ / JPEG ([0-9]+)x([0-9]+) /) {
			if ($1 < $image_size || $2 < $image_size) {
				print STDERR "Image too small: $1x$2\n";
				return 0;
			}
		} else {
			print STDERR "Could not determine image dimensions: $info";
			return 0;
		}
	}

	return $filename;
}

sub archiveorg {
	my $url = shift;
	my $mode = shift || 1;
	my $music = 0;
	my $images = 0;
	my $other = 0;
	my $archives = 0;

	if ($url =~ /^http:\/\/www\.archive.org\/download\/([^\/]+)\//) {
		my $newurl = "http://archive.org/download/$1/$1_files.xml";
		my $xml = get($newurl);
		my $ref = XMLin($xml, ForceArray => 0, KeyAttr => 'files');

		for my $file (@{ $ref->{'file'} }) {
			next if $file->{'source'} eq 'derivative';
			next if $file->{'source'} eq 'metadata';
			next if $file->{'format'} eq 'Metadata';
			next if $file->{'name'} =~ /_rules.conf$/;
			# Formats which are irrelevant
			next if $file->{'name'} =~ /\.(txt|rtf|doc|sfv|nfo|md5|torrent|cue|diz|nml)$/i;
			next if $file->{'name'} =~ /\.(m3u|pls|avi|mpg|swf|wmv|mov)$/i;

			if ($file->{'name'} =~ /\.(mp3|flac|wav|ogg|shn)$/i) {
				$music++;
				next;

			# PDFs are not necessarily images, but let's exclude them for now just in case.
			} elsif ($file->{'name'} =~ /\.(jpg|gif|bmp|png|psd|jpeg|pdf)$/i) {
				$images++;

			} elsif ($file->{'name'} =~ /\.(zip|rar|7z)$/i) {
				$archives++;
			} else {
				$other++;
				print $file->{'format'}, "\n";
				print "Unrecognised file: ", $file->{'name'}, "\n";
			}
		}

		if ($other > 0) {
			print "$url: Unrecognised files found.\n";
		} elsif ($images >= 1 && $archives == 0 && $music == 0 && $mode == 2) {
			print "$url: No music, upload the image.\n";
			return 1;
		} elsif ($images == 1 && $mode == 1) {
			print "$url: Only one image found, upload it.\n";
			return 1;
		} elsif ($images > 1) {
			print "$url: Multiple images found.\n";
		}
		return 0;
	} else { return 0; }
}
