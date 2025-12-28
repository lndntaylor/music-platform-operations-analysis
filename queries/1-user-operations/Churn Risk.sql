WITH user_activity AS (
select 
s.user_id,
 u.user_type,
u.geographic_region,
u.is_quebec_resident,
count(s.stream_id) as total_streams,
COUNT(CASE WHEN s.completed = TRUE THEN 1 END) as completed_streams,
ROUND(COUNT(CASE WHEN s.completed = TRUE THEN 1 END) * 100.0 / COUNT(s.stream_id), 1) as completion_rate,
MAX(s.stream_date) as last_stream_date,
DATE_DIFF(CURRENT_DATE(), MAX(s.stream_date), DAY) as days_since_last_stream
FROM `operations-portfolio.music_operations.streams` s
JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  GROUP BY s.user_id, u.user_type, u.geographic_region, u.is_quebec_resident
)

select 
user_id,
user_type,
geographic_region,
is_quebec_resident,
total_streams,
completion_rate,
days_since_last_stream,
CASE 
WHEN days_since_last_stream > 60 THEN 'High Risk'
WHEN days_since_last_stream > 30 THEN 'Medium Risk'
WHEN completion_rate < 50 THEN 'Low Engagement'
ELSE 'Healthy'
END as churn_risk_category
FROM user_activity
WHERE days_since_last_stream > 30 OR completion_rate < 50
ORDER BY days_since_last_stream DESC, completion_rate ASC
LIMIT 100;