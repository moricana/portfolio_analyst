/*
Automated Import Monitoring — Sanitized Portfolio Demo (SQL Server)

Purpose:
1. Detect explicit import errors within each source's configured lookback window.
2. Detect sources without a successful completion event in that window.

Assumptions to validate against the target system:
- check_period_days is a positive integer representing a lookback duration.
- Severity = 1 means an error.
- Successful messages follow the prefixes used below.
- Module/source names match after normalization.
*/

WITH imports AS (
    SELECT
        source_name AS module,
        responsible_email AS responsible,
        TRY_CONVERT(int, check_period_days) AS check_period
    FROM dbo.ImportSources
    WHERE source_name IS NOT NULL
      AND LTRIM(RTRIM(source_name)) <> N''
),

params AS (
    SELECT
        /* Read enough history for the longest configured monitoring window. */
        COALESCE(MAX(CASE WHEN check_period > 0 THEN check_period END), 1) AS max_days
    FROM imports
),

log_events AS (
    SELECT
        a.Id,
        a.EventTime,
        a.UserId,
        LTRIM(RTRIM(a.Module)) AS Module,
        a.Message,
        a.SessionId,
        a.Severity
    FROM dbo.ApplicationLog AS a
    CROSS JOIN params AS p
    WHERE a.Action = N'Import'
      AND a.Module IS NOT NULL
      AND a.EventTime >= DATEADD(day, -p.max_days, GETDATE())
      AND a.EventTime <= GETDATE()
      AND (a.Severity = 1 OR a.Message LIKE N'Import completed%')

    UNION ALL

    SELECT
        a.Id,
        a.EventTime,
        a.UserId,
        LTRIM(RTRIM(
            SUBSTRING(
                a.Action,
                CHARINDEX(N'Import dictionaries:', a.Action)
                    + LEN(N'Import dictionaries:'),
                4000
            )
        )) AS Module,
        a.Message,
        a.SessionId,
        a.Severity
    FROM dbo.ApplicationLog AS a
    CROSS JOIN params AS p
    WHERE a.Action LIKE N'%Import dictionaries:%'
      AND CHARINDEX(N'Import dictionaries:', a.Action) > 0
      AND a.EventTime >= DATEADD(day, -p.max_days, GETDATE())
      AND a.EventTime <= GETDATE()
      AND (a.Severity = 1 OR a.Message LIKE N'Dictionary import completed%')
),

scoped_events AS (
    SELECT
        e.Id,
        e.EventTime,
        e.Module,
        e.Message,
        e.SessionId,
        i.responsible,
        i.check_period,
        e.Severity
    FROM imports AS i
    INNER JOIN log_events AS e
        ON e.Module = i.module
    WHERE i.check_period > 0
      AND e.EventTime >= DATEADD(day, -i.check_period, GETDATE())
      AND e.EventTime <= GETDATE()
),

errors AS (
    SELECT
        Id,
        EventTime,
        Module,
        Message,
        SessionId,
        responsible,
        check_period
    FROM scoped_events
    WHERE Severity = 1
),

missing_completion AS (
    SELECT
        i.module,
        i.responsible,
        i.check_period
    FROM imports AS i
    WHERE i.check_period > 0
      AND NOT EXISTS (
          SELECT 1
          FROM scoped_events AS e
          WHERE e.Module = i.module
            AND (
                e.Message LIKE N'Import completed%'
                OR e.Message LIKE N'Dictionary import completed%'
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

UNION ALL

SELECT
    CAST(NULL AS bigint) AS Id,
    GETDATE() AS EventTime,
    module AS Module,
    N'Successful completion message was not found within the configured lookback window.' AS Message,
    CAST(NULL AS uniqueidentifier) AS SessionId,
    responsible,
    check_period,
    N'Missing completion' AS incident_type
FROM missing_completion
WHERE responsible IS NOT NULL

ORDER BY Module, EventTime DESC;

/* Validation checklist:
   - Test check_period_days = 1 and 7 with known events inside/outside the window.
   - Confirm the real datatype of ApplicationLog.Id and SessionId; adjust NULL casts if needed.
   - Confirm dictionary import module extraction exactly matches ImportSources.source_name.
   - Decide whether an import is expected every day or only on a schedule. If schedules vary,
     compare against expected run times rather than treating any missing completion as an incident.
*/
