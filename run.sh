#!/bin/bash

MAX=${2:-100}

case $1 in
	cdbaby )
		psql -qtA -F $'\t' musicbrainz < cdbaby.sql > /tmp/data-cdbaby && perl bot.pl --max=$MAX --note="Added from existing cdbaby.com cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release." --remove-note="Added to CAA from existing cdbaby.com cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. The release is no longer available on cdbaby.com so this relationship cannot be converted into another relationship." /tmp/data-cdbaby arturito
	;;

	liveweb )
		psql -qtA -F $'\t' musicbrainz < liveweb.sql > /tmp/data-liveweb && perl bot.pl --max=$MAX --note="Added from existing liveweb.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim})." --remove-note="Added to CAA from existing liveweb.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim})." --image-size=250 /tmp/data-liveweb arturito
	;;

	# this one does not remove http://liveweb.archive.org/ from the URL
	liveweb2 )
		psql -qtA -F $'\t' musicbrainz < liveweb2.sql > /tmp/data-liveweb2 && perl bot.pl --max=$MAX --note="Added from existing liveweb.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim})." --remove-note="Added to CAA from existing liveweb.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim})." --image-size=250 /tmp/data-liveweb2 arturito
	;;

	wwwarchiveorg )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --note="Added from existing www.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim}). The release has a free download relationship for the same directory as the image and the format is digital media." --remove-note="Added to CAA from existing www.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim}). The release has a free download relationship for the same directory as the image and the format is digital media." --image-size=250 /tmp/data-$1 arturito
	;;

	wwwarchiveorg-oneimage )
		psql -qtA -F $'\t' musicbrainz < wwwarchiveorg.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --note="Added from existing www.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains only one image (image dimensions: {\$x_dim}x{\$y_dim}). The release has a free download relationship for the same directory as the image and the format is digital media." --remove-note="Added to CAA from existing www.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains only one image (image dimensions: {\$x_dim}x{\$y_dim}). The release has a free download relationship for the same directory as the image and the format is digital media." --archive-one-image --use-front /tmp/data-$1 arturito
	;;

	wwwarchiveorg-nomusic )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --note="Added from existing www.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains an image (image dimensions: {\$x_dim}x{\$y_dim}) but no music files." --remove-note="Added from existing www.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains an image (image dimensions: {\$x_dim}x{\$y_dim}) but no music files." --archive-no-music --use-front /tmp/data-$1 arturito
	;;

	webarchiveorg )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --note="Added from existing web.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim})." --remove-note="Added to CAA from existing web.archive.org cover art relationship (URL: {\$url}). The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 250x250 (actual dimensions: {\$x_dim}x{\$y_dim})." --image-size=250 /tmp/data-$1 arturito
	;;

	jamendo )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --use-front --note="Image fetched from existing Jamendo download relationship. The release format is digital media. The label is Jamendo and the cat# matches the URL. The release has no other URL relationships (ignoring license URLs) and the URL is only linked to one release. Image dimensions: {\$x_dim}x{\$y_dim}." --image-size=100 /tmp/data-$1 arturito
	;;

	beatport )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --use-front --note="Image fetched from existing Beatport download relationship. The release format is digital media. The release has no other URL relationships (ignoring license URLs) and the URL is only linked to one release. Image dimensions: {\$x_dim}x{\$y_dim}." --image-size=100 /tmp/data-$1 arturito
	;;

	itunes )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --use-front --note="Image fetched from existing iTunes download relationship. The release format is digital media. The release has no other URL relationships (ignoring license URLs) and the URL is only linked to one release. Image dimensions: {\$x_dim}x{\$y_dim}." --image-size=100 /tmp/data-$1 arturito
	;;

	amazoncn )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --use-front --note="Image fetched from existing ASIN relationship for Amazon.cn. The release has no other URL relationships (ignoring license URLs) and the URL is only linked to one release. Image dimensions: {\$x_dim}x{\$y_dim}." --image-size=100 /tmp/data-$1 arturito
	;;

	* )
		echo "Nothing to do"
	;;
esac

