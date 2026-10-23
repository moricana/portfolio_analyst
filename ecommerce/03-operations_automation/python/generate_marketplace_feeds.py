"""Generate validated store-specific price and inventory YAML feeds.

Expected workbook columns are two-level headers, e.g. ('Product', 'SKU') and
('<store name>', 'Price'). Output files are written next to this script's
working directory; use a dedicated output directory for production workflows.
"""
from pathlib import Path
import math
import pandas as pd
import yaml

INPUT_FILE = Path("price_inventory.xlsx")
REQUIRED_PRODUCT_COLUMNS = {("Product", "SKU"), ("Product", "Name")}


def _valid_identifier(value: object) -> bool:
    return pd.notna(value) and str(value).strip() != ""


def create_yml_files(excel_file: Path) -> list[Path]:
    """Create price and quantity feeds and return the generated file paths."""
    if not excel_file.exists():
        raise FileNotFoundError(f"Input workbook not found: {excel_file.resolve()}")

    data = pd.read_excel(excel_file, header=[0, 1])
    missing = REQUIRED_PRODUCT_COLUMNS.difference(set(data.columns))
    if missing:
        raise ValueError(f"Workbook is missing required columns: {sorted(missing)}")

    stores = sorted({col[0] for col in data.columns if col[0] != "Product"})
    if not stores:
        raise ValueError("No store columns found in the workbook")

    output_files: list[Path] = []
    for store in stores:
        price_columns = [(store, "Price"), (store, "Old Price")]
        quantity_column = (store, "Available Quantity")

        if not all(column in data.columns for column in price_columns):
            # Do not silently create incomplete price feeds for malformed sheets.
            raise ValueError(f"Store {store!r} is missing Price or Old Price columns")
        if quantity_column not in data.columns:
            raise ValueError(f"Store {store!r} is missing Available Quantity column")

        price_data = data[[('Product', 'SKU'), ('Product', 'Name'), *price_columns]].copy()
        price_data.columns = ["sku", "name", "price", "old_price"]
        price_data = price_data[
            price_data["sku"].map(_valid_identifier)
            & price_data["name"].map(_valid_identifier)
            & price_data["price"].notna()
        ]

        quantity_data = data[[('Product', 'SKU'), ('Product', 'Name'), quantity_column]].copy()
        quantity_data.columns = ["sku", "name", "quantity"]
        quantity_data = quantity_data[
            quantity_data["sku"].map(_valid_identifier)
            & quantity_data["name"].map(_valid_identifier)
            & quantity_data["quantity"].notna()
        ]

        for column in ("price", "old_price"):
            if column == "old_price":
                # Old price may be blank when the item has no previous price.
                price_data[column] = pd.to_numeric(price_data[column], errors="coerce")
            else:
                price_data[column] = pd.to_numeric(price_data[column], errors="raise")
        price_data["price"] = price_data["price"].astype(float)
        price_data = price_data.where(pd.notna(price_data), None)

        quantity_data["quantity"] = pd.to_numeric(quantity_data["quantity"], errors="raise")
        if (quantity_data["quantity"] < 0).any():
            raise ValueError(f"Store {store!r} has negative inventory quantities")
        if not all(math.isfinite(float(x)) for x in price_data["price"]):
            raise ValueError(f"Store {store!r} has non-finite prices")

        safe_store = "".join(ch if ch.isalnum() or ch in "-_" else "_" for ch in str(store)).strip("_")
        if not safe_store:
            raise ValueError(f"Store name {store!r} cannot be used in an output filename")
        price_path = Path(f"{safe_store}_prices.yml")
        quantity_path = Path(f"{safe_store}_quantities.yml")

        with price_path.open("w", encoding="utf-8") as file:
            yaml.safe_dump({"products": price_data.to_dict("records")}, file,
                           allow_unicode=True, sort_keys=False)
        with quantity_path.open("w", encoding="utf-8") as file:
            yaml.safe_dump({"products": quantity_data.to_dict("records")}, file,
                           allow_unicode=True, sort_keys=False)
        output_files.extend([price_path, quantity_path])

    return output_files


if __name__ == "__main__":
    for output in create_yml_files(INPUT_FILE):
        print(f"Created: {output.resolve()}")
