SET search_path TO musicbrainz;
SELECT r.gid, url.url, NULL, NULL, lru.id
FROM url
JOIN l_release_url lru ON lru.entity1 = url.id
JOIN release r ON r.id = lru.entity0
JOIN link l ON l.id = lru.link
JOIN link_type lt ON lt.id = l.link_type

JOIN l_release_url lru2 ON lru2.entity0 = lru.entity0
JOIN link l2 ON l2.id = lru2.link
JOIN link_type lt2 ON lt2.id = l2.link_type
JOIN url url2 ON url2.id=lru2.entity1

JOIN medium m on m.release = r.id
JOIN medium_format mf on mf.id = m.format

WHERE url.url ~ E'^http://www.archive.org/download/.*.jpg$'
AND lt.name = 'cover art link'
AND lru.edits_pending = 0

AND lt2.name = 'download for free'
AND url2.url = regexp_replace(url.url, 'http://www.archive.org/download/([^/]+)/.*', E'http://www.archive.org/details/\\1')

AND mf.name = 'Digital Media'

-- exclude releases with more than one cover art URL
AND lru.entity0 NOT IN (
	SELECT entity0
	FROM l_release_url lru
	JOIN url ON url.id = entity1
	JOIN link l ON l.id = lru.link
	JOIN link_type lt ON lt.id = l.link_type
	WHERE lt.name = 'cover art link'
	GROUP BY entity0 HAVING COUNT(*) > 1
)

-- exclude URLs linked to more than one release
AND lru.entity1 NOT IN (
	SELECT entity1
	FROM l_release_url lru
	JOIN url ON url.id = entity1
	JOIN link l ON l.id = lru.link
	JOIN link_type lt ON lt.id = l.link_type
	WHERE lt.name = 'cover art link'
	GROUP BY entity1 HAVING COUNT(*) > 1
)

ORDER BY url;
