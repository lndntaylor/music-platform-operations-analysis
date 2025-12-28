WITH user_playlist_behavior AS (
  SELECT 
    u.user_id,
    u.user_type,
    u.is_quebec_resident,
    COUNT(s.stream_id) as total_streams,
    COUNT(CASE WHEN s.added_to_playlist = TRUE THEN 1 END) as playlist_additions,
    ROUND(COUNT(CASE WHEN s.added_to_playlist = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as playlist_usage_rate,
    ROUND(COUNT(CASE WHEN s.replayed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as replay_rate
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  GROUP BY u.user_id, u.user_type, u.is_quebec_resident
  HAVING COUNT(s.stream_id) >= 5
)

SELECT 
  CASE 
    WHEN playlist_usage_rate >= 20 THEN 'High Playlist User'
    WHEN playlist_usage_rate >= 10 THEN 'Medium Playlist User'
    WHEN playlist_usage_rate > 0 THEN 'Light Playlist User'
    ELSE 'Non-Playlist User'
  END as playlist_user_segment,
  user_type,
  is_quebec_resident,
  COUNT(user_id) as user_count,
  ROUND(AVG(total_streams), 1) as avg_streams,
  ROUND(AVG(playlist_usage_rate), 1) as avg_playlist_rate,
  ROUND(AVG(replay_rate), 1) as avg_replay_rate,
  ROUND(
    COUNT(CASE WHEN user_type = 'Premium' THEN 1 END) * 100.0 / COUNT(user_id), 
    1
  ) as premium_conversion_rate
FROM user_playlist_behavior
GROUP BY 
  CASE 
    WHEN playlist_usage_rate >= 20 THEN 'High Playlist User'
    WHEN playlist_usage_rate >= 10 THEN 'Medium Playlist User'
    WHEN playlist_usage_rate > 0 THEN 'Light Playlist User'
    ELSE 'Non-Playlist User'
  END,
  user_type,
  is_quebec_resident
ORDER BY 
  CASE playlist_user_segment
    WHEN 'High Playlist User' THEN 1
    WHEN 'Medium Playlist User' THEN 2
    WHEN 'Light Playlist User' THEN 3
    ELSE 4
  END,
  user_type;