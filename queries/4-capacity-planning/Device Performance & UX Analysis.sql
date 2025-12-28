WITH device_performance AS (
  SELECT 
    s.device_type,
    u.user_type,
    COUNT(s.stream_id) as total_streams,
    COUNT(DISTINCT s.user_id) as unique_users,
    ROUND(COUNT(CASE WHEN s.completed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as completion_rate,
    ROUND(COUNT(CASE WHEN s.skipped = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as skip_rate,
    ROUND(AVG(CAST(s.stream_duration_sec AS FLOAT64)), 0) as avg_stream_duration,
    ROUND(AVG(CAST(s.stream_duration_sec AS FLOAT64)) / AVG(CAST(t.track_duration_sec AS FLOAT64)) * 100, 1) as avg_listen_through_pct
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  JOIN `operations-portfolio.music_operations.tracks` t ON s.track_id = t.track_id
  GROUP BY s.device_type, u.user_type
)

SELECT 
  device_type,
  user_type,
  total_streams,
  unique_users,
  completion_rate,
  skip_rate,
  avg_stream_duration,
  avg_listen_through_pct,
  ROUND(
    (completion_rate * 0.5) + 
    ((100 - skip_rate) * 0.3) + 
    (avg_listen_through_pct * 0.2),
    1
  ) as device_experience_score,
  CASE 
    WHEN skip_rate > 50 THEN 'Critical - High Skip Rate'
    WHEN completion_rate < 60 THEN 'Needs Improvement - Low Completion'
    WHEN avg_listen_through_pct < 70 THEN 'Monitor - Short Listen Time'
    ELSE 'Healthy Performance'
  END as ux_priority
FROM device_performance
ORDER BY device_experience_score ASC;