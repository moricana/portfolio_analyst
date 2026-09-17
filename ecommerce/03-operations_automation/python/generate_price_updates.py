"""Generate SQL UPDATE statements from a CSV of actual prices."""
import csv
from pathlib import Path

INPUT_FILE = Path("actual_prices.csv")
OUTPUT_FILE = Path("price_updates.sql")


def generate_sql() -> None:
    with INPUT_FILE.open("r", encoding="utf-8", newline="") as source, \
         OUTPUT_FILE.open("w", encoding="utf-8") as target:
        reader = csv.DictReader(
            source,
            fieldnames=["order_number", "actual_price"],
            delimiter=";",
        )
        for row in reader:
            order_number = row["order_number"].replace("'", "''")
            actual_price = row["actual_price"]
            target.write(
                "UPDATE public.order_items "
                f"SET actual_price = {actual_price} "
                f"WHERE order_number = '{order_number}';\n"
            )


if __name__ == "__main__":
    generate_sql()
