#!/bin/bash

MAX=${2:-100}

case $1 in
	cdbaby )
		psql -qtA -F $'\t' musicbrainz < cdbaby.sql > /tmp/data-cdbaby && perl bot.pl --max=$MAX --note="Added from existing cdbaby.com cover art relationship. The release has only one cover art relationship and the URL is only linked to one release." --remove-note="Added to CAA from existing cdbaby.com cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. The release is no longer available on cdbaby.com so this relationship cannot be converted into another relationship." /tmp/data-cdbaby arturito
	;;

	liveweb )
		psql -qtA -F $'\t' musicbrainz < liveweb.sql > /tmp/data-liveweb && perl bot.pl --max=$MAX --note="Added from existing liveweb.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 500x500." --remove-note="Added to CAA from existing liveweb.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 500x500." --image-size=500 /tmp/data-liveweb arturito
	;;

	# this one does not remove http://liveweb.archive.org/ from the URL
	liveweb2 )
		psql -qtA -F $'\t' musicbrainz < liveweb2.sql > /tmp/data-liveweb2 && perl bot.pl --max=$MAX --note="Added from existing liveweb.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 500x500." --remove-note="Added to CAA from existing liveweb.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 500x500." --image-size=500 /tmp/data-liveweb2 arturito
	;;

	wwwarchiveorg )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --note="Added from existing www.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 500x500. The release has a free download relationship for the same directory as the image and the format is digital media." --remove-note="Added to CAA from existing www.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. Image size is at least 500x500. The release has a free download relationship for the same directory as the image and the format is digital media." --image-size=500 /tmp/data-$1 arturito
	;;

	wwwarchiveorg-oneimage )
		psql -qtA -F $'\t' musicbrainz < wwwarchiveorg.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --note="Added from existing www.archive.org cover art relationship (URL: %(url)s). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains only one image (image dimensions: %(x_dim)sx%(y_dim)s). The release has a free download relationship for the same directory as the image and the format is digital media." --remove-note="Added to CAA from existing www.archive.org cover art relationship (URL: %(url)s). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains only one image (image dimensions: %(x_dim)sx%(y_dim)s). The release has a free download relationship for the same directory as the image and the format is digital media." --archive-one-image --use-front /tmp/data-$1 arturito
	;;

	wwwarchiveorg-nomusic )
		psql -qtA -F $'\t' musicbrainz < $1.sql > /tmp/data-$1 && perl bot.pl --max=$MAX --note="Added from existing www.archive.org cover art relationship (URL: %(url)s). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains an image (image dimensions: %(x_dim)sx%(y_dim)s) but no music files." --remove-note="Added from existing www.archive.org cover art relationship (URL: %(url)s). The release has only one cover art relationship and the URL is only linked to one release. The archive.org directory contains an image (image dimensions: %(x_dim)sx%(y_dim)s) but no music files." --archive-no-music --use-front /tmp/data-$1 arturito
	;;


	* )
		echo "Nothing to do"
	;;
esac

