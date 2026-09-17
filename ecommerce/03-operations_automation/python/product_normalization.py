"""Normalize product records with one serial number per row."""
from pathlib import Path
import pandas as pd

INPUT_FILE = Path("products.csv")
OUTPUT_FILE = Path("products_normalized.csv")


def normalize() -> None:
    data = pd.read_csv(INPUT_FILE)
    rows = []

    for _, row in data.iterrows():
        serial_numbers = str(row["serial_number"]).splitlines()
        quantity = row["quantity"]

        for serial in serial_numbers:
            new_row = row.copy()
            new_row["serial_number"] = serial.strip()
            new_row["quantity"] = 1 if quantity > 1 else quantity
            rows.append(new_row)

    pd.DataFrame(rows).to_csv(OUTPUT_FILE, index=False, encoding="utf-8")


if __name__ == "__main__":
    normalize()
