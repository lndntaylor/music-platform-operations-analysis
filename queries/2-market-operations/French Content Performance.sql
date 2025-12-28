WITH track_performance AS (
  SELECT 
    t.is_french_language,
    t.genre,
    COUNT(s.stream_id) as total_streams,
    COUNT(DISTINCT s.user_id) as unique_listeners,
    ROUND(AVG(CAST(s.stream_duration_sec AS FLOAT64)), 0) as avg_stream_duration,
    ROUND(COUNT(CASE WHEN s.completed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as completion_rate,
    ROUND(COUNT(CASE WHEN s.replayed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as replay_rate,
    ROUND(COUNT(CASE WHEN s.added_to_playlist = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as playlist_add_rate
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.tracks` t ON s.track_id = t.track_id
  GROUP BY t.is_french_language, t.genre
)

SELECT 
  CASE 
    WHEN is_french_language = TRUE THEN 'French'
    ELSE 'Non-French'
  END as language_category,
  genre,
  total_streams,
  unique_listeners,
  ROUND(total_streams * 1.0 / unique_listeners, 1) as streams_per_listener,
  avg_stream_duration,
  completion_rate,
  replay_rate,
  playlist_add_rate,
  ROUND(
    (completion_rate * 0.35) + 
    (replay_rate * 0.35) + 
    (playlist_add_rate * 0.30), 
    1
  ) as content_performance_score
FROM track_performance
ORDER BY genre, is_french_language DESC;