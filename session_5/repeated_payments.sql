SELECT COUNT(*)
FROM
(SELECT transaction_id, merchant_id, credit_card_id, amount, transaction_timestamp,
LAG(transaction_timestamp) OVER (PARTITION BY merchant_id,credit_card_id, amount ORDER BY transaction_timestamp) AS fecha_comparison
FROM transactions) a
WHERE ABS(EXTRACT (EPOCH FROM (fecha_comparison-transaction_timestamp)))<=600;
