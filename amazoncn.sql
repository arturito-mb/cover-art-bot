SET search_path TO musicbrainz;
begin transaction;

	SELECT entity0
	INTO TEMP hasrels
	FROM l_release_url lru
	JOIN link l ON l.id = lru.link
	JOIN link_type lt ON lt.id = l.link_type
	WHERE lt.name NOT IN ('license')
	GROUP BY entity0 HAVING COUNT(*) > 1
;

SELECT q.gid, q.url, NULL, NULL, NULL, q.lid
FROM (
	SELECT r.gid, r.id AS rid, url, lru.id AS lid, lru.link, lru.entity0, lru.entity1
	FROM url
	JOIN l_release_url lru ON lru.entity1 = url.id
	JOIN release r ON r.id = lru.entity0
	WHERE url ~ 'amazon.cn'
	AND lru.edits_pending = 0
) AS q
JOIN release_meta rm ON rm.id=q.rid
JOIN link l ON l.id = q.link
--JOIN link_type lt ON lt.id = l.link_type

WHERE l.link_type = 77 -- lt.name = 'amazon asin'
AND rm.cover_art_presence = 'absent'

AND q.entity0 NOT IN (
	SELECT entity0
	FROM hasrels
)

AND q.entity1 NOT IN (
	SELECT entity1
	FROM l_release_url lru
	GROUP BY entity1 HAVING COUNT(*) > 1
)
;

commit;
