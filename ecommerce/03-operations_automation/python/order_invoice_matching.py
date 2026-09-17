"""Order–Invoice Matching — sanitized portfolio example."""
import re
from pathlib import Path
import openpyxl

INPUT_FILE = Path("invoices.xlsx")
OUTPUT_FILE = Path("orders_and_invoices.xlsx")
SHEET_NAME = "invoices"
ORDER_PATTERN = re.compile(r"order\D*(\d{9,})", re.IGNORECASE)


def build_mapping() -> None:
    workbook = openpyxl.load_workbook(INPUT_FILE)
    invoice_sheet = workbook[SHEET_NAME]

    result_sheet = (
        workbook["Orders_and_Invoices"]
        if "Orders_and_Invoices" in workbook.sheetnames
        else workbook.create_sheet("Orders_and_Invoices")
    )

    result_sheet.delete_rows(1, result_sheet.max_row)
    result_sheet.cell(1, 1, "Order Number")
    result_sheet.cell(1, 2, "Invoice Number")

    result_row = 2
    for row in invoice_sheet.iter_rows(min_row=2, values_only=True):
        invoice_number = str(row[1]).strip() if row[1] is not None else ""
        description = str(row[3]).strip() if row[3] is not None else ""
        for order_number in ORDER_PATTERN.findall(description):
            result_sheet.cell(result_row, 1, order_number)
            result_sheet.cell(result_row, 2, invoice_number)
            result_row += 1

    workbook.save(OUTPUT_FILE)


if __name__ == "__main__":
    build_mapping()
