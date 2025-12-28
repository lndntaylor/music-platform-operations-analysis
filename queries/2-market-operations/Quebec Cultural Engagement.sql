WITH user_french_consumption AS (
  SELECT 
    s.user_id,
    u.is_quebec_resident,
    u.geographic_region,
    u.user_type,
    COUNT(s.stream_id) as total_streams,
    COUNT(CASE WHEN t.is_french_language = TRUE THEN 1 END) as french_streams,
    ROUND(COUNT(CASE WHEN t.is_french_language = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as french_content_pct
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  JOIN `operations-portfolio.music_operations.tracks` t ON s.track_id = t.track_id
  GROUP BY s.user_id, u.is_quebec_resident, u.geographic_region, u.user_type
  HAVING COUNT(s.stream_id) >= 5
)

SELECT 
  user_id,
  geographic_region,
  user_type,
  is_quebec_resident,
  total_streams,
  french_streams,
  french_content_pct,
  ROUND(
    (CASE WHEN is_quebec_resident = TRUE THEN 60 ELSE 0 END) +
    (french_content_pct * 0.4),
    1
  ) as quebec_affinity_score,
  CASE 
    WHEN is_quebec_resident = TRUE AND french_content_pct >= 30 THEN 'Core Quebec Audience'
    WHEN is_quebec_resident = TRUE AND french_content_pct >= 15 THEN 'Quebec Resident - Moderate French'
    WHEN is_quebec_resident = TRUE THEN 'Quebec Resident - Low French'
    WHEN french_content_pct >= 25 THEN 'Non-Quebec Francophile'
    ELSE 'General Audience'
  END as audience_segment
FROM user_french_consumption
ORDER BY quebec_affinity_score DESC
LIMIT 100;