WITH quality_checks AS (
SELECT 
'Orphaned Streams (No User Match)' as check_type,
 COUNT(*) as issue_count,
'Critical' as severity
  FROM `operations-portfolio.music_operations.streams` s
  LEFT JOIN `operations-portfolio.music_operations.users` u ON s.user_id = u.user_id
  WHERE u.user_id IS NULL
  
  UNION ALL
  
SELECT 
    'Orphaned Streams (No Track Match)',
    COUNT(*),
    'Critical'
  FROM `operations-portfolio.music_operations.streams` s
  LEFT JOIN `operations-portfolio.music_operations.tracks` t ON s.track_id = t.track_id
  WHERE t.track_id IS NULL
  
  UNION ALL
  
SELECT 
    'Impossible Stream Duration (> Track Duration)',
    COUNT(*),
    'High'
  FROM `operations-portfolio.music_operations.streams` s
  JOIN `operations-portfolio.music_operations.tracks` t ON s.track_id = t.track_id
  WHERE CAST(s.stream_duration_sec AS INT64) > CAST(t.track_duration_sec AS INT64)
  
  UNION ALL
  
SELECT 
    'Logic Error (Completed=TRUE but Skipped=TRUE)',
    COUNT(*),
    'Medium'
  FROM `operations-portfolio.music_operations.streams`
  WHERE completed = TRUE AND skipped = TRUE
  
  UNION ALL
  
SELECT 
    'Logic Error (Stream Duration = 0)',
    COUNT(*),
    'Medium'
  FROM `operations-portfolio.music_operations.streams`
  WHERE CAST(stream_duration_sec AS INT64) = 0
  
  UNION ALL
  
SELECT 
    'Missing Geographic Region',
    COUNT(*),
    'Low'
  FROM `operations-portfolio.music_operations.users`
  WHERE geographic_region IS NULL OR TRIM(geographic_region) = ''
)

SELECT 
check_type,
issue_count,
severity,
  CASE 
    WHEN issue_count = 0 THEN '✓ PASSED'
    WHEN severity = 'Critical' THEN '✗ IMMEDIATE ACTION REQUIRED'
    WHEN severity = 'High' THEN '⚠ INVESTIGATE SOON'
    ELSE '! MONITOR'
  END as status
FROM quality_checks
ORDER BY 
  CASE severity
    WHEN 'Critical' THEN 1
    WHEN 'High' THEN 2
    WHEN 'Medium' THEN 3
    ELSE 4
  END,
  issue_count DESC;
