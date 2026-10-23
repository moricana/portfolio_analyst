"""Generate reviewable SQL UPDATE statements from a semicolon-delimited CSV.

Expected columns: order_number;actual_price. The input must include a header.
Generated SQL is a review artifact and should be validated before execution.
"""
import csv
from decimal import Decimal, InvalidOperation
from pathlib import Path

INPUT_FILE = Path("actual_prices.csv")
OUTPUT_FILE = Path("price_updates.sql")


def _parse_price(value: str, row_number: int) -> Decimal:
    try:
        price = Decimal(value.strip().replace(",", "."))
    except (InvalidOperation, AttributeError) as exc:
        raise ValueError(f"Invalid actual_price on CSV row {row_number}: {value!r}") from exc
    if not price.is_finite() or price < 0:
        raise ValueError(f"Price must be finite and non-negative on row {row_number}")
    return price.quantize(Decimal("0.01"))


def generate_sql(input_file: Path = INPUT_FILE, output_file: Path = OUTPUT_FILE) -> int:
    if not input_file.exists():
        raise FileNotFoundError(f"Input CSV not found: {input_file.resolve()}")

    statements: list[str] = []
    seen_orders: set[str] = set()
    with input_file.open("r", encoding="utf-8-sig", newline="") as source:
        reader = csv.DictReader(source, delimiter=";")
        required = {"order_number", "actual_price"}
        if reader.fieldnames is None or not required.issubset(set(reader.fieldnames)):
            raise ValueError("CSV must contain headers: order_number;actual_price")

        for row_number, row in enumerate(reader, start=2):
            order_number = (row.get("order_number") or "").strip()
            raw_price = (row.get("actual_price") or "").strip()
            if not order_number:
                raise ValueError(f"Missing order_number on CSV row {row_number}")
            if order_number in seen_orders:
                raise ValueError(f"Duplicate order_number {order_number!r} on CSV row {row_number}")
            seen_orders.add(order_number)
            price = _parse_price(raw_price, row_number)
            escaped_order = order_number.replace("'", "''")
            statements.append(
                "UPDATE public.order_items "
                f"SET actual_price = {price} "
                f"WHERE order_number = '{escaped_order}';"
            )

    with output_file.open("w", encoding="utf-8", newline="\n") as target:
        target.write("-- Generated SQL. Review row counts and backup data before execution.\n")
        target.write("BEGIN;\n")
        target.write("\n".join(statements))
        target.write("\nCOMMIT;\n")
    return len(statements)


if __name__ == "__main__":
    count = generate_sql()
    print(f"Generated {count} UPDATE statement(s) in {OUTPUT_FILE.resolve()}")
