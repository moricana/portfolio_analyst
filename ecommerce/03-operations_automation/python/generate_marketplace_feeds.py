"""Generate store-specific price and inventory YAML feeds."""
from pathlib import Path
import pandas as pd
import yaml

INPUT_FILE = Path("price_inventory.xlsx")


def create_yml_files(excel_file: Path) -> None:
    data = pd.read_excel(excel_file, header=[0, 1])
    sku_col = ("Product", "SKU")
    name_col = ("Product", "Name")
    stores = sorted({col[0] for col in data.columns if col[0] != "Product"})

    for store in stores:
        price_data = data[[
            sku_col, name_col, (store, "Price"), (store, "Old Price")
        ]].dropna()
        quantity_data = data[[
            sku_col, name_col, (store, "Available Quantity")
        ]].dropna()

        price_data.columns = ["sku", "name", "price", "old_price"]
        quantity_data.columns = ["sku", "name", "quantity"]

        with open(f"{store}_prices.yml", "w", encoding="utf-8") as file:
            yaml.dump({"products": price_data.to_dict("records")}, file,
                      allow_unicode=True, sort_keys=False)

        with open(f"{store}_quantities.yml", "w", encoding="utf-8") as file:
            yaml.dump({"products": quantity_data.to_dict("records")}, file,
                      allow_unicode=True, sort_keys=False)


if __name__ == "__main__":
    create_yml_files(INPUT_FILE)
