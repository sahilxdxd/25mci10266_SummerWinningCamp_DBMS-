SELECT DISTINCT f.user_id
FROM (
    SELECT
        user_id,
        MIN(created_at) AS first_purchase
    FROM amazon_transactions
    GROUP BY user_id
) f
JOIN amazon_transactions p
    ON f.user_id = p.user_id
WHERE p.created_at > f.first_purchase
  AND p.created_at <= f.first_purchase + INTERVAL '7 day';
