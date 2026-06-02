
WITH max_dt AS
(
    SELECT MAX(event_timestamp::date) AS latest_date
    FROM search_events
),

user_segment AS
(
    SELECT
        a.user_id,
        CASE
            WHEN a.registration_date >=
                 (SELECT latest_date - INTERVAL '30 days'
                  FROM max_dt)
            THEN 'new'
            ELSE 'existing'
        END AS segment
    FROM accounts a
),

first_click AS
(
    SELECT
        s.event_id AS search_id,
        s.user_id,
        s.event_timestamp AS search_time,
        c.event_timestamp AS click_time,
        ROW_NUMBER() OVER
        (
            PARTITION BY s.event_id
            ORDER BY c.event_timestamp
        ) AS rn
    FROM search_events s
    LEFT JOIN search_events c
        ON s.user_id = c.user_id
       AND s.session_id = c.session_id
       AND s.query = c.query
       AND c.event_type = 'click'
       AND c.event_timestamp > s.event_timestamp
    WHERE s.event_type = 'search'
),

search_result AS
(
    SELECT
        fc.search_id,
        fc.user_id,
        CASE
            WHEN fc.click_time IS NOT NULL
             AND fc.click_time <= fc.search_time + INTERVAL '30 seconds'
            THEN 1
            ELSE 0
        END AS successful_search
    FROM first_click fc
    WHERE fc.rn = 1
       OR fc.rn IS NULL
)

SELECT
    us.segment,
    COUNT(*) AS total_searches,
    SUM(successful_search) AS successful_searches,
    ROUND(
        SUM(successful_search)::numeric
        / COUNT(*),
        2
    ) AS success_rate
FROM search_result sr
JOIN user_segment us
    ON sr.user_id = us.user_id
GROUP BY us.segment
ORDER BY us.segment;
