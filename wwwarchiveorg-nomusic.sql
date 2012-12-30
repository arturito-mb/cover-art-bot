SET search_path TO musicbrainz;
SELECT DISTINCT r.gid, url.url, NULL, NULL, lru.id, lru.last_updated
FROM url
JOIN l_release_url lru ON lru.entity1 = url.id
JOIN release r ON r.id = lru.entity0
JOIN link l ON l.id = lru.link
JOIN link_type lt ON lt.id = l.link_type

WHERE url.url ~* E'^http://www.archive.org/download/.*.jpe?g$'
AND lt.name = 'cover art link'
AND lru.edits_pending = 0

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

ORDER BY url DESC;
