#!/bin/bash

MAX=${2:-100}

case $1 in
	cdbaby )
		psql -qtA -F $'\t' musicbrainz < cdbaby.sql > /tmp/data-cdbaby && perl bot.pl --max=$MAX --note="Added from existing cdbaby.com cover art relationship. The release has only one cover art relationship and the URL is only linked to one release." --remove-note="Added to CAA from existing cdbaby.com cover art relationship. The release has only one cover art relationship and the URL is only linked to one release. The release is no longer available on cdbaby.com so this relationship cannot be converted into another relationship." /tmp/data-cdbaby arturito
	;;

	liveweb )
		psql -qtA -F $'\t' musicbrainz < liveweb.sql > /tmp/data-liveweb && perl bot.pl --max=$MAX --note="Added from existing liveweb.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release." --remove-note="Added to CAA from existing liveweb.archive.org cover art relationship. The release has only one cover art relationship and the URL is only linked to one release." /tmp/data-liveweb arturito
	;;

	* )
		echo "Nothing to do"
	;;
esac

