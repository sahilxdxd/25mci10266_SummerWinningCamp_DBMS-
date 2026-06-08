WITH valid_tasks AS (
    SELECT DISTINCT
           task_id,
           task_name,
           start_time,
           end_time
    FROM task_schedule
    WHERE start_time IS NOT NULL
      AND end_time IS NOT NULL
),
events AS (
    SELECT start_time AS event_time, 1 AS cpu_change
    FROM valid_tasks

    UNION ALL

    SELECT end_time AS event_time, -1 AS cpu_change
    FROM valid_tasks
),
running_tasks AS (
    SELECT
        event_time,
        SUM(cpu_change) OVER (
            ORDER BY event_time, cpu_change
        ) AS active_tasks
    FROM events
)
SELECT MAX(active_tasks) AS min_cpus_required
FROM running_tasks;
