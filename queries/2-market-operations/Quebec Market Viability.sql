WITH artist_streams AS (
SELECT 
t.artist_name,
t.genre,
COUNT(s.stream_id) as total_streams,
COUNT(DISTINCT s.user_id) as unique_listeners,
COUNT(CASE WHEN u.user_type = 'Premium' THEN 1 END) as premium_streams,
COUNT(CASE WHEN u.user_type = 'Free' THEN 1 END) as free_streams,
ROUND(COUNT(CASE WHEN s.completed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as completion_rate
FROM `operations-portfolio.music_operations.streams` s
JOIN `operations-portfolio.music_operations.tracks` t ON s.track_id = t.track_id
JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
GROUP BY t.artist_name, t.genre
)

SELECT 
artist_name,
genre,
total_streams,
unique_listeners,
premium_streams,
free_streams,
completion_rate,
ROUND((premium_streams * 0.004) + (free_streams * 0.0025), 2) as estimated_royalty_value,
ROUND(total_streams * 1.0 / unique_listeners, 1) as streams_per_listener,
CASE 
WHEN (premium_streams * 0.004) + (free_streams * 0.0025) >= 10 THEN 'Tier 1 - High Value'
WHEN (premium_streams * 0.004) + (free_streams * 0.0025) >= 5 THEN 'Tier 2 - Medium Value'
WHEN (premium_streams * 0.004) + (free_streams * 0.0025) >= 2 THEN 'Tier 3 - Growing'
ELSE 'Tier 4 - Emerging'
END as partnership_tier
FROM artist_streams
ORDER BY estimated_royalty_value DESC
LIMIT 50;
