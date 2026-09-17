# E-commerce Operations Automation

**Business / Data Analyst · Python · Pandas · OpenPyXL · SQL**

## Overview

Built lightweight automation tools to reduce repetitive operations around marketplace data: order/invoice matching, product normalization, actual-price updates and store-specific price/inventory feeds.

## Problem

Several operational processes required repeated manual work in Excel / CSV files. The goal was to turn them into repeatable, script-based workflows.

## 1. Order–Invoice Matching

Extract order numbers from invoice descriptions and generate an explicit **Order Number → Invoice Number** mapping.

```text
Invoice Excel → Regex / Text Parsing → Order Extraction → Mapping Sheet
```

## 2. Product Data Normalization

Split multiple serial numbers stored in one row into separate records and adjust quantity to one record per serial number.

```text
Product X | Qty 3 | A / B / C
                    ↓
Product X | A | 1
Product X | B | 1
Product X | C | 1
```

## 3. Automated Price Updates

Transform a CSV containing order numbers and actual prices into SQL UPDATE statements for downstream database processing.

```text
CSV → Read fields → Generate SQL → Batch-ready file
```

## 4. Price & Inventory Feed Generation

Process a multi-level Excel file and generate separate YAML feeds for each store:

- SKU;
- product name;
- price;
- old price;
- available quantity.

```text
Excel
 ↓
Split by Store
 ↓
Price Feed + Inventory Feed
 ↓
Store-specific YAML files
```

## My Contribution

- identified repetitive manual operations;
- designed transformation logic;
- implemented Python automation;
- used regex for structured text extraction;
- normalized operational datasets;
- generated SQL update statements;
- generated marketplace price and inventory feeds.

## Technologies

Python · Pandas · OpenPyXL · PyYAML · Regex · SQL · Excel / CSV

## Key Outcome

Converted repetitive spreadsheet operations into repeatable, auditable data-processing workflows.
