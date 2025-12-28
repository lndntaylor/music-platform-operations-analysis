WITH user_engagement AS (
  SELECT 
    s.user_id,
    u.user_type,
    u.geographic_region,
    u.is_quebec_resident,
    COUNT(s.stream_id) as total_streams,
    ROUND(COUNT(CASE WHEN s.completed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as completion_rate,
    ROUND(COUNT(CASE WHEN s.replayed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as replay_rate,
    ROUND(COUNT(CASE WHEN s.added_to_playlist = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as playlist_add_rate
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  GROUP BY s.user_id, u.user_type, u.geographic_region, u.is_quebec_resident
  HAVING COUNT(s.stream_id) >= 3
)

SELECT 
  user_id,
  user_type,
  geographic_region,
  is_quebec_resident,
  total_streams,
  completion_rate,
  replay_rate,
  playlist_add_rate,
  ROUND(
    (completion_rate * 0.4) + 
    (replay_rate * 0.3) + 
    (playlist_add_rate * 0.3), 
    1
  ) as engagement_quality_score,
  CASE 
    WHEN (completion_rate * 0.4 + replay_rate * 0.3 + playlist_add_rate * 0.3) >= 40 THEN 'Power User'
    WHEN (completion_rate * 0.4 + replay_rate * 0.3 + playlist_add_rate * 0.3) >= 25 THEN 'Engaged User'
    WHEN (completion_rate * 0.4 + replay_rate * 0.3 + playlist_add_rate * 0.3) >= 15 THEN 'Casual User'
    ELSE 'At-Risk User'
  END as user_segment
FROM user_engagement
ORDER BY engagement_quality_score DESC
LIMIT 100;