SELECT
    s.date,
    AVG(
        CASE
            WHEN a.user_id_sender IS NOT NULL THEN 1.0
            ELSE 0
        END
    ) AS acceptance_rate
FROM fb_friend_requests s
LEFT JOIN fb_friend_requests a
    ON s.user_id_sender = a.user_id_sender
   AND s.user_id_receiver = a.user_id_receiver
   AND a.action = 'accepted'
WHERE s.action = 'sent'
GROUP BY s.date
HAVING COUNT(a.user_id_sender) > 0
ORDER BY s.date;
