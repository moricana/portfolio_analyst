# Analytical Dataset — Data Model

The portfolio dataset uses generic names to illustrate the transformation from transactional data to BI-ready data.

## Fact table

`financial_transactions`

Main fields:

| Field | Purpose |
|---|---|
| `operation_date` | Transaction date |
| `amount_primary` | Primary amount |
| `amount_secondary` | Secondary currency amount |
| `source_account` | Source account |
| `destination_account` | Destination account |
| `legal_entity_id` | Legal entity reference |
| `category_id` | Business category |
| `report_type_id` | Reporting type |
| `budget_id` | Budget / plan reference |
| `factor_group_id` | Analytical factor |

## Dimensions

- `dim_legal_entity`
- `dim_category`
- `dim_report_type`
- `dim_budget`
- `dim_adjustment`
- `dim_factor_group`

## Output

The final analytical view `vw_financial_analytics` is designed for BI consumption and contains:

- amount;
- currency;
- account;
- month;
- legal entity;
- category;
- report type;
- budget;
- adjustment;
- factor;
- plan status.
