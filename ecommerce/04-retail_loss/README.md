# Retail Loss Analysis

**Role focus:** Data Analyst  
**Tools:** Python, pandas, NumPy, Matplotlib, Jupyter Notebook  
**Data status:** fully synthetic; results are for demonstrating analytical methods, not describing a real retailer.

## Business questions

1. **Revenue changes:** when does revenue fall below a reference level, and which categories contribute to the observed change?
2. **Promotion performance:** how do category revenues during promotional periods compare with a pre-promotion reference period?
3. **Returns:** how large are refunds relative to gross sales, and which categories have higher observed refund rates?

## Workflow

- generate reproducible synthetic product, customer, transaction, promotion and return data;
- inspect daily and category-level patterns;
- calculate comparison metrics;
- visualize patterns;
- document limitations and propose follow-up analysis.

## Run locally

From this directory:

```bash
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install pandas numpy matplotlib seaborn jupyter
jupyter notebook retail_loss_analysis_for_github.ipynb
```

Run the notebook from top to bottom. Generated files should be saved to a project-local `output/` directory rather than a machine-specific path such as `/mnt/data/`.

## Interpretation notes

- A daily revenue value below the overall mean is a screening signal, not by itself proof of a business decline. Compare like-for-like weekdays, account for seasonality and investigate data completeness.
- A before/during promotion comparison is descriptive. It does not prove that the promotion caused an uplift; seasonality, pricing, inventory and other campaigns may also affect results. A control group or experiment is needed for stronger causal claims.
- Refund amounts should ideally be linked to the original order item and sale date. Aggregating refunds by their processing date can distort category-level comparisons.
- Any numerical findings should be generated directly from the current notebook run. Do not publish fixed percentage claims unless the notebook calculates and validates them.

## Recommended next steps

1. Add explicit calculations for percentage change and category contribution to total change.
2. Compare equivalent weekdays and use a rolling baseline as a sensitivity check.
3. Report promotion-period and pre-period revenue per day, not only totals, when the period lengths differ.
4. Match returns to original sales where possible and state the refund-rate denominator.
5. Add data-quality checks for missing dates, duplicate transaction IDs and refunds greater than the original sale value.

## Portfolio note

This is a method demonstration built on synthetic data. Findings should not be interpreted as evidence about a real company's performance.
