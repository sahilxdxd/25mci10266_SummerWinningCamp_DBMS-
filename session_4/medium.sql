SELECT
    "date",
    SUM(CASE WHEN a.paying_customer = 'no'  THEN d.downloads ELSE 0 END) AS non_paying_downloads,
    SUM(CASE WHEN a.paying_customer = 'yes' THEN d.downloads ELSE 0 END) AS paying_downloads
FROM ms_user_dimension u
JOIN ms_acc_dimension a
    ON u.acc_id = a.acc_id
JOIN ms_download_facts d
    ON u.user_id = d.user_id
GROUP BY "date"
HAVING
    SUM(CASE WHEN a.paying_customer = 'no'  THEN d.downloads ELSE 0 END) >
    SUM(CASE WHEN a.paying_customer = 'yes' THEN d.downloads ELSE 0 END)
ORDER BY "date";
