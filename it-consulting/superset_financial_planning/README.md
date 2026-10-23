# Financial Planning & Cash Flow Analytics

**Business / Data Analyst · SQL · Apache Superset**

> **Portfolio case:** sanitized reconstruction of a financial analytics solution.
> Production company names, database names, internal IDs, identifiers and source data have been removed.

## Overview

Designed and developed financial analytics dashboards in **Apache Superset** to provide management with a unified view of cash flows, budget execution and financial performance.

The solution transformed transactional financial data into an analytical dataset and interactive dashboards covering:

- actual vs planned cash flow;
- cash inflows and outflows;
- cash balances;
- plan execution;
- project revenue;
- financial performance;
- cash flow drivers.

## Business Problem

Management needed a consolidated view of financial performance across business units, legal entities and projects.

The main questions were:

1. How does actual cash flow compare with plan?
2. Which areas drive changes in net cash flow?
3. Which projects contribute most to revenue?
4. Where are the largest plan-vs-actual deviations?
5. Which areas may require additional cash-flow attention?

## Solution

```text
Financial Transactions
        ↓
SQL Transformation
        ↓
Analytical Dataset
        ↓
Apache Superset
        ↓
Management Dashboards
        ↓
Financial Insights
```

## Analytical Dataset

The SQL layer:

- filtered and aggregated financial transactions;
- separated cash inflows and outflows;
- transformed transactional fields into business dimensions;
- joined legal entity, category, reporting, budget and factor dimensions;
- created a monthly analytical date;
- prepared a dataset for BI dashboards.

See [`sql/financial_analytics_dataset.sql`](sql/financial_analytics_dataset.sql).

## Data model and validation considerations

The SQL view is a demonstration of the transformation approach, not a plug-and-play production model. Before using an equivalent view, confirm:

- **Grain:** whether each source row represents a transaction, transaction line, account movement or budget line.
- **Cash-flow sign convention:** inflows are positive and outflows negative in the analytical output; internal transfers may appear as both an outflow and inflow at account level and should net to zero only when grouped consistently.
- **Currency:** amounts in different currencies must not be summed together without a documented conversion rate and reporting-currency policy.
- **Budget mapping:** a non-null budget dimension is not necessarily sufficient to classify a row as planned; use an explicit plan/actual flag if the source provides one.
- **Join cardinality:** dimension keys should be unique. Validate row counts and totals before and after joins to avoid duplicated amounts.
- **Reconciliation:** compare monthly and account-level totals against source-system reports for a known period.

See [`docs/data_model.md`](docs/data_model.md) and [`docs/dashboard_structure.md`](docs/dashboard_structure.md) for the current model and dashboard notes.

## Dashboards

### 1. Cash Flow Management

**Purpose:** monitor actual and planned cash flows and current cash position.

Key views:

- actual cash inflows;
- planned cash inflows;
- actual cash outflows;
- planned cash outflows;
- plan execution;
- cash balance;
- cash flow by business direction.

### 2. Cash Flow Drivers

**Purpose:** identify the factors contributing to changes in net cash flow.

A waterfall-style view breaks the overall change down into individual business drivers.

### 3. Project Revenue

**Purpose:** compare planned and actual revenue across projects.

The dashboard allows users to identify:

- major revenue contributors;
- revenue concentration;
- plan-vs-actual deviations.

### 4. Financial Performance

**Purpose:** analyze profitability across business units and legal entities.

The dashboard supports comparison of financial results and the contribution of different business areas.

## My Contribution

- Analyzed business requirements for management reporting
- Defined analytical indicators and dimensions
- Translated financial business logic into SQL
- Designed the analytical dataset for BI
- Built interactive dashboards in Apache Superset
- Created plan-vs-actual and cash-flow analysis
- Developed visualizations for project and business-unit performance
- Translated financial data into management-oriented views

## Key Insights

The dashboard was designed not only for reporting, but to support financial decision-making:

- identify deviations from plan early;
- understand the main drivers of cash flow changes;
- identify projects with significant revenue contribution;
- detect potential cash flow gaps;
- focus management attention on the areas with the largest financial impact.

## Technologies

- MS SQL Server
- Apache Superset
- SQL
- Financial / management reporting

## Portfolio Note

The original project used internal enterprise data. This repository contains only a **sanitized portfolio version**. Real company names, projects, internal IDs, database objects and source values are intentionally excluded.

The published dashboard screenshots are illustrative portfolio visuals. Review them for residual identifiers and confirm that the displayed values are not presented as verified production outcomes.
