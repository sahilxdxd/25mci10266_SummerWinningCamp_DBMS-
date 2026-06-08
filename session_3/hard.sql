WITH cte AS (
    SELECT
        product_name,
        month_start AS decline_start_month,

        monthly_active_users AS m1,
        LEAD(monthly_active_users,1) OVER(PARTITION BY product_id ORDER BY month_start) AS m2,
        LEAD(monthly_active_users,2) OVER(PARTITION BY product_id ORDER BY month_start) AS m3,
        LEAD(monthly_active_users,3) OVER(PARTITION BY product_id ORDER BY month_start) AS m4,
        LEAD(monthly_active_users,4) OVER(PARTITION BY product_id ORDER BY month_start) AS m5,
        LEAD(monthly_active_users,5) OVER(PARTITION BY product_id ORDER BY month_start) AS m6,
        LEAD(monthly_active_users,6) OVER(PARTITION BY product_id ORDER BY month_start) AS m7,

        LEAD(month_start,3) OVER(PARTITION BY product_id ORDER BY month_start) AS growth_resumed_month
    FROM product_engagement
)

SELECT
    product_name,
    decline_start_month,
    growth_resumed_month,
    ROUND((m7 - m4) * 1.0 / m4, 2) AS growth_ratio
FROM cte
WHERE
      m1 > m2
  AND m2 > m3
  AND m3 > m4      -- 3 consecutive declines
  AND m4 < m5
  AND m5 < m6
  AND m6 < m7;     -- 3 consecutive growth months
