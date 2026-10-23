# E-commerce Operations Automation

**Role focus:** Data Analyst / Operations Analyst  
**Tools:** Python, pandas, openpyxl, PyYAML, CSV/Excel  
**Data status:** sample inputs are illustrative; scripts are intended as local demos.

## Business problem

Repeated spreadsheet workflows can introduce manual errors and consume time. This case demonstrates how small scripts can make selected transformations repeatable, reviewable and easier to validate.

## Workflows

### 1. Order–invoice matching

Extract order numbers from invoice descriptions and create an order-to-invoice mapping workbook. Duplicate order/invoice pairs are skipped; missing input files and worksheets produce explicit errors.

### 2. Product normalization

Split line-separated serial numbers into one record per serial number, with quantity set to one per serial. Records without serial numbers are retained as untracked inventory rather than assigned fabricated identifiers.

### 3. Price-update SQL generation

Validate the required CSV headers, parse prices as decimal values, reject missing/duplicate order numbers and generate a transaction-wrapped SQL review file. **Review generated statements and verify affected-row counts before execution.** The target table and key are illustrative and must be adapted to the actual schema.

### 4. Price and inventory feeds

Read a two-row-header Excel workbook and generate separate YAML feeds for prices and available quantities per store. Required columns are validated, incomplete rows are filtered according to each feed's own required fields, and negative inventory values are rejected.

## Run locally

From this directory, install dependencies:

```bash
python -m venv .venv
# Windows: .venv\Scripts\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
```

Place the relevant input file in the working directory using the expected name shown in each script, then run the script from that directory. For example:

```bash
python python/product_normalization.py
```

Input file names and expected columns are documented in each script. Do not use production data or execute generated SQL without review.

## Data-quality safeguards

- Validate input file existence and required columns.
- Reject missing identifiers and invalid numeric values where appropriate.
- Detect duplicate order numbers before generating updates.
- Keep generated files reviewable and avoid publishing real customer, invoice or product identifiers.

## Limitations

The included example CSVs are small fixtures, not a representative performance benchmark. These scripts do not replace business approval, database transactions, logging, access control or a production test suite. Before production use, add automated tests for malformed files, duplicate keys, missing values and unexpected source formats.

## Skills

Python · pandas · openpyxl · PyYAML · CSV/Excel Processing · Data Validation · Data Transformation · Operational Automation
