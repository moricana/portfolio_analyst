/*
Email Notification — Sanitized Portfolio Demo

Purpose:
Generate a structured HTML table and send it to the responsible user.

This is a simplified/anonymized version of the notification pattern used
in the original environment.
*/

DECLARE @recipients nvarchar(320);
DECLARE @html nvarchar(MAX);
DECLARE @query nvarchar(MAX);

-- In production, the recipient is resolved from the responsible user.
SET @recipients = N'responsible@example.com';

SET @query = N'
SELECT
    document_number AS [Document Number],
    CAST(created_at AS date) AS [Created Date],
    CAST(payment_date AS date) AS [Payment Date],
    payment_method AS [Payment Method],
    legal_entity AS [Legal Entity],
    business_unit AS [Business Unit],
    counterparty AS [Counterparty],
    amount AS [Amount],
    expected_document_date AS [Expected Document Date]
FROM dbo.Documents
WHERE expected_document_date <= GETDATE()
  AND status = N''Waiting for documents''
ORDER BY expected_document_date;
';

-- The helper procedure converts the query result into an HTML table.
EXEC dbo.QueryToHtmlTable
    @query = @query,
    @html = @html OUTPUT;

SET @html =
    N'<p>Good morning, below is the list of documents requiring action.</p>'
    + @html;

EXEC msdb.dbo.sp_send_dbmail
    @profile_name = N'YOUR_MAIL_PROFILE',
    @recipients = @recipients,
    @subject = N'Documents requiring action',
    @body = @html,
    @body_format = N'HTML',
    @query_no_truncate = 1,
    @attach_query_result_as_file = 0;
