/*
Automated Import Monitoring — Sanitized Portfolio Demo

Purpose:
Detect:
1. Explicit import errors.
2. Missing successful-completion messages within the configured period.

This is a portfolio/demo adaptation of a production monitoring approach.
Table and field names are anonymized.
*/

WITH imports AS (
    SELECT
        source_name AS module,
        responsible_email AS responsible,
        check_period_days AS check_period
    FROM dbo.ImportSources
    WHERE source_name IS NOT NULL
      AND LTRIM(RTRIM(source_name)) <> N''
),

params AS (
    SELECT
        CAST(COALESCE(MIN(check_period), 0) AS int) AS max_days
    FROM imports
),

import_logs AS (
    SELECT
        a.Id,
        a.EventTime,
        a.UserId,
        a.Module,
        a.Message,
        a.SessionId,
        a.Severity
    FROM dbo.ApplicationLog a
    CROSS JOIN params p
    WHERE a.Action = N'Import'
      AND (
            a.Severity = 1
            OR a.Message LIKE N'Import completed%'
          )
      AND a.EventTime >= DATEADD(day, p.max_days, GETDATE())
      AND a.Module IS NOT NULL
),

dictionary_logs AS (
    SELECT
        a.Id,
        a.EventTime,
        a.UserId,
        CASE
            WHEN CHARINDEX(N'Import dictionaries:', a.Action) > 0 THEN
                LTRIM(RTRIM(SUBSTRING(
                    a.Action,
                    CHARINDEX(N'Import dictionaries:', a.Action)
                        + LEN(N'Import dictionaries:'),
                    4000
                )))
            ELSE NULL
        END AS Module,
        a.Message,
        a.SessionId,
        a.Severity
    FROM dbo.ApplicationLog a
    CROSS JOIN params p
    WHERE a.Action LIKE N'%Import dictionaries:%'
      AND (
            a.Severity = 1
            OR a.Message LIKE N'Dictionary import completed%'
          )
      AND a.EventTime >= DATEADD(day, p.max_days, GETDATE())
),

errors AS (
    SELECT
        a.Id,
        a.EventTime,
        a.Module,
        a.Message,
        a.SessionId,
        i.responsible,
        i.check_period
    FROM imports i
    JOIN (
        SELECT * FROM import_logs
        UNION ALL
        SELECT * FROM dictionary_logs
    ) a
        ON a.Module = i.module
    WHERE
        (i.check_period IS NULL
         OR a.EventTime >= DATEADD(day, i.check_period, GETDATE()))
        AND a.Severity = 1
),

missing_completion AS (
    SELECT
        i.module,
        i.responsible,
        i.check_period
    FROM imports i
    WHERE NOT EXISTS (
        SELECT 1
        FROM (
            SELECT Module, EventTime, Message
            FROM import_logs
            WHERE Message LIKE N'Import completed%'

            UNION ALL

            SELECT Module, EventTime, Message
            FROM dictionary_logs
            WHERE Message LIKE N'Dictionary import completed%'
        ) completed
        WHERE completed.Module = i.module
          AND (
                i.check_period IS NULL
                OR completed.EventTime >= DATEADD(
                    day, i.check_period, GETDATE()
                )
              )
    )
)

SELECT
    Id,
    EventTime,
    Module,
    Message,
    SessionId,
    responsible,
    check_period,
    N'Explicit error' AS incident_type
FROM errors
WHERE responsible IS NOT NULL
  AND check_period IS NOT NULL

UNION ALL

SELECT
    CAST(NULL AS bigint) AS Id,
    GETDATE() AS EventTime,
    module AS Module,
    N'Successful completion message was not found for the configured period.'
        AS Message,
    CAST(NULL AS uniqueidentifier) AS SessionId,
    responsible,
    check_period,
    N'Missing completion' AS incident_type
FROM missing_completion
WHERE responsible IS NOT NULL
  AND check_period IS NOT NULL

ORDER BY Module, EventTime DESC;
