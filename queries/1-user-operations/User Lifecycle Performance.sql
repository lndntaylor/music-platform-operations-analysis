WITH first_stream AS (
  SELECT 
    user_id,
    MIN(stream_date) as first_stream_date
  FROM `operations-portfolio.music_operations.streams`
  GROUP BY user_id
),
user_metrics AS (
  SELECT 
    fs.user_id,
    u.user_type,
    u.geographic_region,
    u.is_quebec_resident,
    fs.first_stream_date,
    FORMAT_DATE('%Y-%m', fs.first_stream_date) as cohort_month,
    COUNT(s.stream_id) as total_streams,
    COUNT(DISTINCT s.stream_date) as active_days,
    ROUND(AVG(CAST(s.stream_duration_sec AS FLOAT64)), 0) as avg_stream_duration
  FROM first_stream fs
  JOIN `operations-portfolio.music_operations.users` u ON fs.user_id = u.user_id
  JOIN `operations-portfolio.music_operations.streams` s ON fs.user_id = s.user_id
  GROUP BY fs.user_id, u.user_type, u.geographic_region, u.is_quebec_resident, fs.first_stream_date
)

SELECT 
  cohort_month,
  user_type,
  is_quebec_resident,
  COUNT(DISTINCT user_id) as cohort_size,
  ROUND(AVG(total_streams), 1) as avg_streams_per_user,
  ROUND(AVG(active_days), 1) as avg_active_days,
  ROUND(AVG(avg_stream_duration), 0) as avg_duration_seconds
FROM user_metrics
GROUP BY cohort_month, user_type, is_quebec_resident
ORDER BY cohort_month, user_type, is_quebec_resident;