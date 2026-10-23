/*
Sanitized portfolio SQL example.

- Generic source table/column names are illustrative; source DDL and seed data
  are not bundled with this example.
- Validate table grain, join cardinality, currency policy and accounting rules
  before adapting this query to another schema.
- This query does not claim production-ready profitability accounting.
*/

WITH order_items_base AS (
    SELECT
        oi.id AS order_item_id,
        oi.order_number,
        oi.product_name,
        /* Keep the source quantity at order-item grain. Do not divide by the
           number of items in an order unless a documented allocation rule says so. */
        COALESCE(oi.quantity, 0) AS quantity,
        COALESCE(ROUND(oi.sale_price, 2), 0) AS sale_price
    FROM public.order_items AS oi
),

/* Aggregate one-to-many financial detail to product grain before joining.
   If product_commissions is already unique by product_id, this CTE is still
   safe; if it contains multiple periods/currencies, add those dimensions to
   the grouping and join keys before using the result. */
commission_costs AS (
    SELECT
        pc.product_id,
        SUM(COALESCE(pc.advertising_cost_actual, 0)) AS advertising_cost_actual,
        SUM(COALESCE(pc.marketplace_commission_actual, 0)) AS marketplace_commission_actual,
        SUM(COALESCE(pc.payment_fee_actual, 0)) AS payment_fee_actual,
        SUM(COALESCE(pc.delivery_cost_actual, 0)) AS delivery_cost_actual,
        SUM(COALESCE(pc.acquiring_cost_actual, 0)) AS acquiring_cost_actual,
        SUM(COALESCE(pc.withdrawal_fee_actual, 0)) AS withdrawal_fee_actual,
        SUM(COALESCE(pc.logistics_cost_actual, 0)) AS logistics_cost_actual,
        SUM(COALESCE(pc.penalty_actual, 0)) AS penalty_actual,
        SUM(COALESCE(pc.advertising_cost_plan, 0)) AS advertising_cost_plan,
        SUM(COALESCE(pc.marketplace_commission_plan, 0)) AS marketplace_commission_plan,
        SUM(COALESCE(pc.payment_fee_plan, 0)) AS payment_fee_plan,
        SUM(COALESCE(pc.delivery_cost_plan, 0)) AS delivery_cost_plan,
        SUM(COALESCE(pc.acquiring_cost_plan, 0)) AS acquiring_cost_plan,
        SUM(COALESCE(pc.withdrawal_fee_plan, 0)) AS withdrawal_fee_plan,
        SUM(COALESCE(pc.logistics_cost_plan, 0)) AS logistics_cost_plan,
        SUM(COALESCE(pc.customer_income_plan, 0)) AS customer_income_plan,
        SUM(COALESCE(pc.customer_profit_plan, 0)) AS customer_profit_plan,
        SUM(COALESCE(pc.customer_profit_actual, 0)) AS customer_profit_actual
    FROM public.product_commissions AS pc
    GROUP BY pc.product_id
),

calculated_data AS (
    SELECT
        o.marketplace,
        o.store_name,
        b.order_number,
        b.order_item_id,
        b.product_name,
        o.shipment_date,
        o.order_date,
        os.status_name AS order_status,
        o.status_changed_at,
        o.shipment_warehouse,
        o.warehouse,
        b.quantity AS quantity_sold,
        b.sale_price,
        COALESCE(p.cost_price, 0) AS purchase_price,

        COALESCE(c.advertising_cost_actual, 0) AS advertising_cost_actual,
        COALESCE(c.marketplace_commission_actual, 0) AS marketplace_commission_actual,
        COALESCE(c.payment_fee_actual, 0) AS payment_fee_actual,
        COALESCE(c.delivery_cost_actual, 0) AS delivery_cost_actual,
        COALESCE(c.acquiring_cost_actual, 0) AS acquiring_cost_actual,
        COALESCE(c.withdrawal_fee_actual, 0) AS withdrawal_fee_actual,
        COALESCE(c.logistics_cost_actual, 0) AS logistics_cost_actual,
        COALESCE(c.penalty_actual, 0) AS penalty_actual,

        COALESCE(c.advertising_cost_plan, 0) AS advertising_cost_plan,
        COALESCE(c.marketplace_commission_plan, 0) AS marketplace_commission_plan,
        COALESCE(c.payment_fee_plan, 0) AS payment_fee_plan,
        COALESCE(c.delivery_cost_plan, 0) AS delivery_cost_plan,
        COALESCE(c.acquiring_cost_plan, 0) AS acquiring_cost_plan,
        COALESCE(c.withdrawal_fee_plan, 0) AS withdrawal_fee_plan,
        COALESCE(c.logistics_cost_plan, 0) AS logistics_cost_plan,
        COALESCE(c.customer_income_plan, 0) AS customer_income_plan,
        COALESCE(c.customer_profit_plan, 0) AS customer_profit_plan,
        COALESCE(c.customer_profit_actual, 0) AS customer_profit_actual

    FROM order_items_base AS b
    LEFT JOIN public.orders AS o
        ON o.order_number = b.order_number
    LEFT JOIN public.products AS p
        ON p.order_item_id = b.order_item_id
    LEFT JOIN public.order_statuses AS os
        ON os.id = o.status_id
    LEFT JOIN commission_costs AS c
        ON c.product_id = p.id
)

SELECT
    *,
    advertising_cost_actual
      + marketplace_commission_actual
      + payment_fee_actual
      + delivery_cost_actual
      + acquiring_cost_actual
      + withdrawal_fee_actual
      + logistics_cost_actual
      + penalty_actual AS total_cost_actual,

    advertising_cost_plan
      + marketplace_commission_plan
      + payment_fee_plan
      + delivery_cost_plan
      + acquiring_cost_plan
      + withdrawal_fee_plan
      + logistics_cost_plan AS total_cost_plan,

    CASE
        WHEN product_name ILIKE '%phone%' THEN 'Smartphone'
        WHEN product_name ILIKE '%tablet%' THEN 'Tablet'
        WHEN product_name ILIKE '%laptop%' THEN 'Laptop'
        ELSE 'Other'
    END AS product_category
FROM calculated_data;

/* Suggested validation checks (adapt source names before running):
   1. Confirm orders.order_number is unique, or join through a unique order key.
   2. Confirm products.order_item_id is unique, or aggregate products to order-item grain.
   3. Reconcile row counts before/after each join to detect fan-out.
   4. Confirm monetary columns share one currency and one consistent grain.
   5. Compare calculated totals with source totals for a known sample period.
*/
