/*
Generic SQL helper — portfolio/demo version.

Converts an arbitrary SELECT result into a basic HTML table.
This demonstrates the mechanism used to prepare SQL results for email.
*/

CREATE OR ALTER PROCEDURE dbo.QueryToHtmlTable
(
    @query nvarchar(MAX),
    @html nvarchar(MAX) OUTPUT
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @columns nvarchar(MAX);
    DECLARE @header nvarchar(MAX);

    SELECT * INTO #query_result
    FROM (
        -- The real implementation dynamically injects the supplied query.
        -- Replace this section with your environment-specific implementation.
        SELECT
            N'DEMO' AS [Status],
            N'Example' AS [Message]
    ) AS source_data;

    SELECT
        @columns = COALESCE(@columns + N', ', N'')
                 + N'[' + name + N'] AS td'
    FROM tempdb.sys.columns
    WHERE object_id = OBJECT_ID(N'tempdb..#query_result')
    ORDER BY column_id;

    SELECT
        @header = COALESCE(@header + N'', N'')
                + N'<th>' + name + N'</th>'
    FROM tempdb.sys.columns
    WHERE object_id = OBJECT_ID(N'tempdb..#query_result')
    ORDER BY column_id;

    SET @header = N'<tr>' + @header + N'</tr>';

    SET @html =
        N'<table border="1">'
        + @header
        + N'</table>';
END;
