# Marketplace Profitability & Operations Analytics

**Role focus:** Data Analyst / BI Analyst  
**Tools:** PostgreSQL, SQL, Apache Superset  
**Data status:** illustrative portfolio data; screenshot values are not production results.

## Business question

How can marketplace sales, costs, returns and budget performance be consolidated into a reliable view that helps management understand profitability and investigate deviations?

## Scope

The reporting concept covers:

- sales volume, turnover and average order value;
- product cost and marketplace-related expenses;
- actual versus planned cost components;
- return monitoring;
- category and date-level trends;
- detailed records for investigation.

## Data flow

```text
Orders + Order Items + Products
              +
Commissions + Logistics + Returns
              ↓
      SQL transformations
              ↓
      Analytical dataset
              ↓
       Apache Superset
```

## Dashboard examples

### Executive overview

Designed to surface high-level sales, profitability and return indicators, then support a deeper investigation of the underlying trends.

![Executive dashboard](screenshots/executive_dashboard.png)

### Marketplace and financial analytics

Provides a more detailed view of cost components, budget variance and order-level records.

![Marketplace analytics dashboard](screenshots/marketplace_analytics.png)

> The original README referenced a returns screenshot that is not included in this repository archive. This link has been removed rather than pointing to a missing file. Add a verified screenshot if that view is available.

## Metric definitions to confirm before production use

The SQL is a portfolio illustration and must be aligned to the actual source schema and accounting rules before use. In particular, validate:

| Metric / rule | Validation required |
|---|---|
| Quantity sold | Confirm whether `quantity` is already recorded at order-item grain; do not divide it by the number of rows in the order unless the source definition requires allocation. |
| Revenue and turnover | Define treatment of cancellations, returns, discounts and taxes. |
| Profit | Document included cost components and whether purchase cost is included in addition to marketplace expenses. |
| Commissions and logistics | Confirm one-to-one or one-to-many relationships before joining; aggregate detail tables to the intended grain to avoid fan-out. |
| Budget variance | Define sign convention and whether the comparison is at the same date, store, category and currency grain. |
| Currency | Do not aggregate different currencies without an explicit conversion policy. |

## SQL implementation

See [`sql/marketplace_analytics_dataset.sql`](sql/marketplace_analytics_dataset.sql).

The query demonstrates CTEs, joins, window functions, conditional categorization and calculated cost totals. It references generic source tables that are not included in the archive, so it is not yet a standalone runnable example. A production-ready public case should add a small synthetic schema and seed data, then include row-count and reconciliation checks.

## Analytical workflow

1. Confirm the grain and primary key of every source table.
2. Profile nulls, duplicate keys and unmatched records.
3. Join order items to order and product dimensions without multiplying rows.
4. Calculate cost components and validate totals against source-level aggregates.
5. Build the BI views and verify that dashboard totals reconcile to the SQL dataset.
6. Translate observed patterns into recommendations only when supported by calculated results.

## My contribution

- translated management questions into reporting requirements;
- designed KPI and dimension concepts;
- developed SQL transformation logic for an analytical dataset;
- organized dashboard views around overview, financial analysis and drill-down;
- considered validation and reconciliation requirements for reporting.

## Limitations and next steps

- Source DDL and a synthetic seed dataset are not included yet.
- Business definitions for revenue, profit, returns and budget need to be documented against the intended source system.
- Dashboard values are illustrative and should not be cited as business achievements.

## Skills

PostgreSQL · SQL · CTEs · Window Functions · JOINs · Aggregations · KPI Design · Apache Superset · E-commerce Analytics
