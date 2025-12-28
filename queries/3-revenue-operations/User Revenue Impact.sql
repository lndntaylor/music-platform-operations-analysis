WITH user_revenue AS (
  SELECT 
    u.user_type,
    u.user_age_group,
    u.geographic_region,
    u.is_quebec_resident,
    COUNT(DISTINCT s.user_id) as user_count,
    COUNT(s.stream_id) as total_streams,
    ROUND(COUNT(s.stream_id) * 1.0 / COUNT(DISTINCT s.user_id), 1) as streams_per_user,
    ROUND(
      COUNT(s.stream_id) * 
      CASE 
        WHEN u.user_type = 'Premium' THEN 0.004
        ELSE 0.0025
      END, 
      2
    ) as estimated_segment_revenue
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  GROUP BY u.user_type, u.user_age_group, u.geographic_region, u.is_quebec_resident
)

SELECT 
  user_type,
  user_age_group,
  geographic_region,
  is_quebec_resident,
  user_count,
  total_streams,
  streams_per_user,
  estimated_segment_revenue,
  ROUND(estimated_segment_revenue / user_count, 2) as revenue_per_user,
  ROUND(
    estimated_segment_revenue * 100.0 / 
    SUM(estimated_segment_revenue) OVER(), 
    1
  ) as pct_of_total_revenue
FROM user_revenue
ORDER BY estimated_segment_revenue DESC;