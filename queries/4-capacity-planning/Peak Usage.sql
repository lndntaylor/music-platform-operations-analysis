WITH hourly_usage AS (
  SELECT 
    CAST(s.hour_of_day AS INT64) as hour,
    s.device_type,
    u.geographic_region,
    COUNT(s.stream_id) as stream_count,
    COUNT(DISTINCT s.user_id) as concurrent_users,
    ROUND(AVG(CAST(s.stream_duration_sec AS FLOAT64)), 0) as avg_stream_duration
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  GROUP BY hour, s.device_type, u.geographic_region
)

SELECT 
  hour,
  device_type,
  geographic_region,
  stream_count,
  concurrent_users,
  avg_stream_duration,
  ROUND(stream_count * 100.0 / SUM(stream_count) OVER(PARTITION BY device_type), 1) as pct_of_device_traffic,
  CASE 
    WHEN hour BETWEEN 18 AND 22 THEN 'Peak Evening'
    WHEN hour BETWEEN 12 AND 14 THEN 'Lunch Rush'
    WHEN hour BETWEEN 6 AND 9 THEN 'Morning Commute'
    WHEN hour BETWEEN 23 AND 5 THEN 'Late Night'
    ELSE 'Off-Peak'
  END as usage_period
FROM hourly_usage
ORDER BY stream_count DESC
LIMIT 100;