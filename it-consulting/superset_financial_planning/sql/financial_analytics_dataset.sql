/*
Financial Planning & Cash Flow Analytics
Sanitized portfolio SQL

IMPORTANT:
This file is a portfolio/demo adaptation.
It does NOT contain production database names, internal IDs,
company names, credentials, or confidential identifiers.
*/

CREATE OR ALTER VIEW dbo.vw_financial_analytics AS

WITH transactions_base AS (
    SELECT
        amount_primary,
        amount_secondary,

        CASE
            WHEN destination_account_group = 'CASH'
              OR destination_account = 'CASH'
            THEN 1 ELSE 0
        END AS destination_cash_flag,

        CASE
            WHEN source_account_group = 'CASH'
              OR source_account = 'CASH'
            THEN 1 ELSE 0
        END AS source_cash_flag,

        YEAR(operation_date)  AS operation_year,
        MONTH(operation_date) AS operation_month,

        primary_currency,
        secondary_currency,
        source_account,
        destination_account,

        legal_entity_id,
        category_id,
        report_type_id,
        budget_id,
        adjustment_id,
        factor_group_id

    FROM dbo.financial_transactions
    WHERE is_reversed = 0
      AND consolidation_flag IS NULL
),

aggregated_transactions AS (
    SELECT
        SUM(amount_primary)   AS amount_primary,
        SUM(amount_secondary) AS amount_secondary,

        destination_cash_flag,
        source_cash_flag,

        operation_year,
        operation_month,

        primary_currency,
        secondary_currency,
        source_account,
        destination_account,

        legal_entity_id,
        category_id,
        report_type_id,
        budget_id,
        adjustment_id,
        factor_group_id

    FROM transactions_base
    WHERE destination_cash_flag = 1
       OR source_cash_flag = 1

    GROUP BY
        primary_currency,
        secondary_currency,
        destination_cash_flag,
        source_cash_flag,
        source_account,
        destination_account,
        operation_year,
        operation_month,
        legal_entity_id,
        category_id,
        report_type_id,
        budget_id,
        adjustment_id,
        factor_group_id
),

cash_flow AS (

    -- Cash inflows
    SELECT
        amount_primary AS amount,
        primary_currency AS currency,
        destination_account AS account,
        operation_year,
        operation_month,

        legal_entity_id,
        category_id,
        report_type_id,
        budget_id,
        adjustment_id,
        factor_group_id

    FROM aggregated_transactions
    WHERE destination_cash_flag = 1

    UNION ALL

    -- Secondary-currency inflows
    SELECT
        amount_secondary AS amount,
        secondary_currency AS currency,
        destination_account AS account,
        operation_year,
        operation_month,

        legal_entity_id,
        category_id,
        report_type_id,
        budget_id,
        adjustment_id,
        factor_group_id

    FROM aggregated_transactions
    WHERE destination_cash_flag = 1
      AND amount_secondary <> 0

    UNION ALL

    -- Cash outflows
    SELECT
        -amount_primary AS amount,
        primary_currency AS currency,
        source_account AS account,
        operation_year,
        operation_month,

        legal_entity_id,
        category_id,
        report_type_id,
        budget_id,
        adjustment_id,
        factor_group_id

    FROM aggregated_transactions
    WHERE source_cash_flag = 1

    UNION ALL

    -- Secondary-currency outflows
    SELECT
        -amount_secondary AS amount,
        secondary_currency AS currency,
        source_account AS account,
        operation_year,
        operation_month,

        legal_entity_id,
        category_id,
        report_type_id,
        budget_id,
        adjustment_id,
        factor_group_id

    FROM aggregated_transactions
    WHERE source_cash_flag = 1
      AND amount_secondary <> 0
)

SELECT
    SUM(amount) AS amount,
    currency,
    account,
    operation_year,
    operation_month,

    COALESCE(le.name, 'Unassigned') AS legal_entity,
    COALESCE(cat.name, 'Unassigned') AS category,
    COALESCE(rt.name, 'Unassigned') AS report_type,
    COALESCE(b.name, 'Unassigned') AS budget,
    COALESCE(a.name, 'Unassigned') AS adjustment,
    COALESCE(f.name, 'Other')     AS factor,

    CASE
        WHEN b.name IS NULL THEN 'Actual'
        ELSE b.name
    END AS plan_status,

    DATEFROMPARTS(operation_year, operation_month, 1) AS operation_month_date

FROM cash_flow cf

LEFT JOIN dbo.dim_legal_entity le
    ON le.id = cf.legal_entity_id

LEFT JOIN dbo.dim_category cat
    ON cat.id = cf.category_id

LEFT JOIN dbo.dim_report_type rt
    ON rt.id = cf.report_type_id

LEFT JOIN dbo.dim_budget b
    ON b.id = cf.budget_id

LEFT JOIN dbo.dim_adjustment a
    ON a.id = cf.adjustment_id

LEFT JOIN dbo.dim_factor_group f
    ON f.id = cf.factor_group_id

WHERE account IS NOT NULL

GROUP BY
    currency,
    account,
    operation_year,
    operation_month,
    legal_entity_id,
    category_id,
    report_type_id,
    budget_id,
    adjustment_id,
    factor_group_id,
    le.name,
    cat.name,
    rt.name,
    b.name,
    a.name,
    f.name

HAVING SUM(amount) <> 0;
