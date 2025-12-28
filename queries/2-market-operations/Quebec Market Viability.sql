WITH market_metrics AS (
  SELECT 
    u.is_quebec_resident,
    u.geographic_region,
    COUNT(DISTINCT s.user_id) as unique_users,
    COUNT(s.stream_id) as total_streams,
    ROUND(AVG(CAST(s.stream_duration_sec AS FLOAT64)), 0) as avg_stream_duration,
    ROUND(COUNT(CASE WHEN s.completed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as completion_rate,
    ROUND(COUNT(CASE WHEN s.added_to_playlist = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as playlist_add_rate,
    COUNT(DISTINCT CASE WHEN u.user_type = 'Premium' THEN s.user_id END) as premium_users,
    ROUND(COUNT(DISTINCT CASE WHEN u.user_type = 'Premium' THEN s.user_id END) * 100.0 / 
          COUNT(DISTINCT s.user_id), 1) as premium_penetration
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  GROUP BY u.is_quebec_resident, u.geographic_region
)

SELECT 
  CASE 
    WHEN is_quebec_resident = TRUE THEN 'Quebec (Montreal)'
    ELSE geographic_region 
  END as market,
  unique_users,
  total_streams,
  ROUND(total_streams * 1.0 / unique_users, 1) as streams_per_user,
  avg_stream_duration,
  completion_rate,
  playlist_add_rate,
  premium_users,
  premium_penetration,
  ROUND(
    (completion_rate * 0.4) + 
    (playlist_add_rate * 0.3) + 
    (premium_penetration * 0.3), 
    1
  ) as market_health_score
FROM market_metrics
ORDER BY market_health_score DESC;