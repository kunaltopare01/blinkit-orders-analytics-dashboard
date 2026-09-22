# Data Dictionary

## blinkit_orders

| Column | Description |
|---|---|
| order_id | Unique order identifier |
| customer_id | Customer identifier |
| order_date | Order placement timestamp |
| promised_delivery_time | Promised delivery timestamp |
| actual_delivery_time | Actual delivery timestamp |
| delivery_status | On Time / Slightly Delayed / Significantly Delayed |
| order_total | Total order value |
| payment_method | Card / Cash / Wallet / UPI |
| delivery_partner_id | Delivery partner identifier |
| store_id | Store identifier |

## blinkit_order_items

| Column | Description |
|---|---|
| order_id | Order identifier |
| product_id | Product identifier |
| quantity | Units purchased |
| unit_price | Selling price per unit |

## blinkit_customers

| Column | Description |
|---|---|
| customer_id | Unique customer identifier |
| customer_name | Customer name |
| area | Customer area |
| pincode | Postal code |
| registration_date | Customer registration date |
| customer_segment | Regular / Premium / New / Inactive |
| total_orders | Customer order count in source |
| avg_order_value | Customer average order value in source |

## blinkit_products

| Column | Description |
|---|---|
| product_id | Unique product identifier |
| product_name | Product name |
| category | Product category |
| brand | Product brand |
| price | Product selling price |
| mrp | Maximum retail price |
| margin_percentage | Product margin percentage |
| shelf_life_days | Product shelf life |
| min_stock_level | Minimum stock level |
| max_stock_level | Maximum stock level |

## blinkit_delivery_performance

| Column | Description |
|---|---|
| order_id | Order identifier |
| delivery_partner_id | Delivery partner |
| promised_time | Promised delivery timestamp |
| actual_time | Actual delivery timestamp |
| delivery_time_minutes | Actual minus promised delivery time |
| distance_km | Delivery distance |
| delivery_status | Delivery status |
| reasons_if_delayed | Delay reason |

## blinkit_customer_feedback

| Column | Description |
|---|---|
| feedback_id | Feedback identifier |
| order_id | Order identifier |
| customer_id | Customer identifier |
| rating | Customer rating |
| feedback_text | Customer feedback |
| feedback_category | Feedback topic |
| sentiment | Sentiment classification |
| feedback_date | Feedback date |

## blinkit_inventory

| Column | Description |
|---|---|
| product_id | Product identifier |
| inventory_date | Inventory date |
| stock_received | Stock received |
| damaged_stock | Damaged stock |

## blinkit_marketing_performance

| Column | Description |
|---|---|
| campaign_id | Campaign identifier |
| campaign_name | Campaign name |
| marketing_date | Campaign date |
| target_audience | Campaign audience |
| channel | Marketing channel |
| impressions | Impressions |
| clicks | Clicks |
| conversions | Conversions |
| spend | Marketing spend |
| revenue_generated | Revenue attributed to marketing |
| roas | Return on ad spend |
