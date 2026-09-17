/*
Marketplace Profitability & Operations Analytics
Sanitized portfolio SQL.

All production identifiers and business-specific names have been replaced
with generic names. The structure demonstrates the analytical approach.
*/

WITH order_items_base AS (
    SELECT
        oi.id,
        oi.order_number,
        oi.product_name,
        COALESCE(
            oi.quantity / NULLIF(COUNT(*) OVER (PARTITION BY oi.order_number), 0),
            0
        ) AS quantity,
        COALESCE(ROUND(oi.sale_price, 2), 0) AS sale_price
    FROM public.order_items oi
),

calculated_data AS (
    SELECT
        o.marketplace,
        o.store_name,
        b.order_number,
        b.product_name,
        o.shipment_date,
        o.order_date,
        os.status_name AS order_status,
        o.status_changed_at,
        o.shipment_warehouse,
        o.warehouse,
        COALESCE(b.quantity, 0) AS quantity_sold,
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

    FROM order_items_base b
    LEFT JOIN public.orders o
        ON o.order_number = b.order_number
    LEFT JOIN public.products p
        ON p.order_item_id = b.id
    LEFT JOIN public.order_statuses os
        ON os.id = o.status_id
    LEFT JOIN public.product_commissions c
        ON c.product_id = p.id
)

SELECT
    *,
    (
        advertising_cost_actual
        + marketplace_commission_actual
        + payment_fee_actual
        + delivery_cost_actual
        + acquiring_cost_actual
        + withdrawal_fee_actual
        + logistics_cost_actual
        + penalty_actual
    ) AS total_cost_actual,

    (
        advertising_cost_plan
        + marketplace_commission_plan
        + payment_fee_plan
        + delivery_cost_plan
        + acquiring_cost_plan
        + withdrawal_fee_plan
        + logistics_cost_plan
    ) AS total_cost_plan,

    CASE
        WHEN product_name ILIKE '%phone%' THEN 'Smartphone'
        WHEN product_name ILIKE '%tablet%' THEN 'Tablet'
        WHEN product_name ILIKE '%laptop%' THEN 'Laptop'
        ELSE 'Other'
    END AS product_category

FROM calculated_data;
