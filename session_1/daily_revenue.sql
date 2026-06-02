WITH purchases AS
(
    SELECT
        transaction_id,
        transaction_date,
        amount
    FROM product_sales
    WHERE product_id = 'PROD-2891'
      AND country = 'US'
      AND status = 'completed'
      AND type = 'purchase'
      AND transaction_date
          BETWEEN '2025-04-15' AND '2025-04-28'
),

daily_revenue AS
(
    SELECT
        p.transaction_date,
        p.amount AS revenue
    FROM purchases p

    UNION ALL

    SELECT
        p.transaction_date,
        r.amount
    FROM purchases p
    JOIN product_sales r
      ON r.original_transaction_id = p.transaction_id
     AND r.status = 'completed'
     AND r.type = 'refund'
),

calendar AS
(
    SELECT generate_series(
        DATE '2025-04-15',
        DATE '2025-04-28',
        INTERVAL '1 day'
    )::date AS transaction_date
)

SELECT
    c.transaction_date,
    COALESCE(SUM(dr.revenue),0) AS daily_net_revenue
FROM calendar c
LEFT JOIN daily_revenue dr
ON c.transaction_date = dr.transaction_date
GROUP BY c.transaction_date
ORDER BY c.transaction_date;
