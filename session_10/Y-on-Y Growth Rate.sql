WITH yearly_spend AS (
    SELECT
        EXTRACT(YEAR FROM transaction_date) AS year,
        product_id,
        spend
    FROM user_transactions
)

SELECT
    y1.year,
    y1.product_id,
    y1.spend AS curr_year_spend,
    (
        SELECT y2.spend
        FROM yearly_spend y2
        WHERE y2.product_id = y1.product_id
          AND y2.year = y1.year - 1
    ) AS prev_year_spend,
    ROUND(
        100.0 * (
            y1.spend -
            (
                SELECT y2.spend
                FROM yearly_spend y2
                WHERE y2.product_id = y1.product_id
                  AND y2.year = y1.year - 1
            )
        ) /
        (
            SELECT y2.spend
            FROM yearly_spend y2
            WHERE y2.product_id = y1.product_id
              AND y2.year = y1.year - 1
        ),
        2
    ) AS yoy_rate
FROM yearly_spend y1;
