"""Normalize product records to one non-empty serial number per row."""
from pathlib import Path
import pandas as pd

INPUT_FILE = Path("products.csv")
OUTPUT_FILE = Path("products_normalized.csv")
REQUIRED_COLUMNS = {"serial_number", "quantity"}


def normalize(input_file: Path = INPUT_FILE, output_file: Path = OUTPUT_FILE) -> int:
    if not input_file.exists():
        raise FileNotFoundError(f"Input CSV not found: {input_file.resolve()}")

    data = pd.read_csv(input_file)
    missing = REQUIRED_COLUMNS.difference(data.columns)
    if missing:
        raise ValueError(f"Input CSV is missing required columns: {sorted(missing)}")

    rows = []
    for row_index, row in data.iterrows():
        raw_serials = row["serial_number"]
        serial_numbers = [] if pd.isna(raw_serials) else [
            value.strip() for value in str(raw_serials).splitlines() if value.strip()
        ]
        quantity = pd.to_numeric(pd.Series([row["quantity"]]), errors="coerce").iloc[0]
        if pd.isna(quantity) or quantity < 0:
            raise ValueError(f"Invalid quantity at input row {row_index + 2}")

        if not serial_numbers:
            # Preserve untracked inventory as a single row instead of creating
            # a fake serial number; retain its original quantity.
            new_row = row.copy()
            new_row["serial_number"] = ""
            new_row["quantity"] = quantity
            rows.append(new_row)
            continue

        if quantity not in (len(serial_numbers), 1) and quantity != int(quantity):
            raise ValueError(f"Non-integer quantity at input row {row_index + 2}")
        for serial in serial_numbers:
            new_row = row.copy()
            new_row["serial_number"] = serial
            new_row["quantity"] = 1
            rows.append(new_row)

    result = pd.DataFrame(rows, columns=data.columns)
    result.to_csv(output_file, index=False, encoding="utf-8")
    return len(result)


if __name__ == "__main__":
    print(f"Wrote {normalize()} normalized row(s) to {OUTPUT_FILE.resolve()}")
