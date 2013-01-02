SET search_path TO musicbrainz;
SELECT DISTINCT r.gid, url, NULL, NULL, NULL, lru.id
FROM url
JOIN l_release_url lru ON lru.entity1 = url.id
JOIN release r ON r.id = lru.entity0
JOIN release_meta rm ON rm.id=r.id
JOIN link l ON l.id = lru.link
JOIN link_type lt ON lt.id = l.link_type

JOIN medium m ON m.release=r.id
JOIN medium_format mf ON mf.id=m.format

WHERE url ~ E'^http://www.beatport.com/'
AND lt.name = 'purchase for download'
AND lru.edits_pending = 0
AND rm.cover_art_presence = 'absent'

AND mf.name = 'Digital Media'

-- exclude releases with more than one URL
AND lru.entity0 NOT IN (
	SELECT entity0
	FROM l_release_url lru
	JOIN url ON url.id = entity1
	JOIN link l ON l.id = lru.link
	JOIN link_type lt ON lt.id = l.link_type
	WHERE lt.name NOT IN ('license')
	GROUP BY entity0 HAVING COUNT(*) > 1
)

-- exclude URLs linked to more than one release
AND lru.entity1 NOT IN (
	SELECT entity1
	FROM l_release_url lru
	GROUP BY entity1 HAVING COUNT(*) > 1
)

ORDER BY url;
