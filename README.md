# Blinkit Orders Analytics Dashboard 🛒📊

## 📌 Project Overview

This project focuses on **business and operational analytics** for a Blinkit-style quick-commerce platform using **SQL and Power BI**.

The goal is to analyze **orders, revenue, customers, products, delivery performance, inventory, customer feedback, and marketing performance** and present the findings through an interactive Power BI dashboard.

The dashboard provides a consolidated view of business performance and helps identify patterns in sales, customer behavior, product performance, delivery efficiency, and marketing effectiveness.

---

## 🎯 Objectives

- Analyze overall order and revenue performance
- Track average order value and order trends over time
- Identify high-performing product categories and products
- Analyze customer segments and customer-level revenue
- Compare order performance across different areas
- Evaluate delivery time and on-time delivery performance
- Analyze product margins and units sold
- Understand inventory and damaged-stock activity
- Evaluate marketing spend, revenue generated, and ROAS
- Build reusable SQL views for Power BI reporting

---

## 📊 Business Questions Answered

1. What is the total number of orders and total revenue?
2. What is the average order value?
3. Which product categories generate the highest revenue?
4. Which areas have the highest number of orders?
5. Which products are most frequently ordered?
6. How are customers distributed across different segments?
7. Which customers generate the highest revenue?
8. What is the average delivery time and on-time delivery rate?
9. How does delivery distance affect delivery time?
10. How do promised and actual delivery times compare?
11. Which products and categories have higher margins?
12. Which products have the highest unit sales?
13. How much inventory is received and damaged?
14. Which marketing channels generate the highest revenue?
15. How does marketing spend compare with revenue generated?

---

## 🛠️ Tools & Technologies

- **MySQL** — data modeling, data validation, KPI calculations, joins, aggregations, CTEs, window functions, and analytical views
- **Power BI** — interactive dashboard, slicers, KPI cards, charts, maps, and business reporting
- **SQL** — business analysis and reusable reporting queries
- **CSV** — source datasets
- **Excel** — dashboard icon and visual assets

---

## 📁 Project Structure

```text
blinkit-orders-analytics-dashboard/
│
├── README.md
├── data_dictionary.md
├── .gitignore
│
├── sql/
│   └── blinkit_orders_analysis.sql
│
├── dashboard/
│   └── Blinkit_Orders_Analytics_Dashboard.pbix
│
├── screenshots/
│   └── dashboard_overview.pdf
│
└── data/
    └── README.md
    └── blinkit_analytics_data
```

---

## 📈 Dashboard Pages

### 🛒 Orders Dashboard

- Total Orders
- Total Revenue
- Average Order Value
- Delivered Orders
- Cancellation Rate
- Average Delivery Time
- Orders over time
- Orders by category
- Revenue by category
- Orders by customer segment
- Top areas by orders
- Top products by orders
- Orders by payment method
- Order-value distribution
- Recent orders

### 👥 Customers Dashboard

- Total Customers
- Average Order Value
- Average Rating
- Total Feedback
- Customer Segments
- Customer Registration Trend
- Customer Distribution by Segment
- Top Customers by Revenue
- Top Areas by Customers

### 📦 Products Dashboard

- Total Products
- Units Sold
- Product Revenue
- Average Selling Price
- Average Margin %
- Average Maximum Stock Level
- Average Margin by Category
- Product Price vs Margin %
- Top Products by Units Sold

### 🚴 Delivery Dashboard

- Average Delivery Time
- On-Time Orders
- Slightly Delayed Orders
- Significantly Delayed Orders
- On-Time Delivery Rate
- Average Distance
- Orders by Delivery Status
- Average Delivery Time by Distance
- Average Delivery Time by Delivery Status
- Promised vs Actual Delivery Time

### 📊 Performance Dashboard

- Total Revenue
- On-Time Delivery Rate
- Average Delivery Time
- Average Order Value
- Average Rating
- Units Sold
- Monthly Orders vs Average Order Value
- Monthly Revenue Growth
- Marketing Spend vs Revenue by Channel

---

## 🔑 Key Dashboard KPIs

| KPI | Value |
|---|---:|
| Total Orders | **5,000** |
| Total Revenue | **₹11.01M** |
| Average Order Value | **₹2,201.86** |
| Average Delivery Time | **19.43 min** |
| On-Time Delivery Rate | **69.40%** |
| Average Rating | **3.34** |
| Total Customers | **2,500** |
| Total Products | **268** |
| Units Sold | **10,034** |
| Product Revenue | **₹4.97M** |
| Average Product Margin | **27.78%** |
| Average Delivery Distance | **2.72 km** |

---

## 🗄️ Dataset Information

The project uses multiple related datasets:

| Dataset | Purpose |
|---|---|
| `blinkit_orders` | Order details, revenue, payment and delivery status |
| `blinkit_order_items` | Products and quantities purchased in each order |
| `blinkit_customers` | Customer, area and customer segment information |
| `blinkit_products` | Product, category, price and margin information |
| `blinkit_delivery_performance` | Delivery time, distance and delay information |
| `blinkit_customer_feedback` | Customer ratings, feedback and sentiment |
| `blinkit_inventory` | Stock received and damaged stock |
| `blinkit_marketing_performance` | Marketing spend, conversions and revenue generated |

---

## 🧮 SQL Analysis

The SQL component includes:

- Database/table creation
- Data-quality checks
- KPI calculations
- Order and revenue analysis
- Customer analysis
- Product analysis
- Delivery analysis
- Inventory analysis
- Marketing analysis
- CTE-based analysis
- Window functions
- Conditional logic using `CASE`
- Aggregations and grouping
- Reusable SQL views for Power BI

### Reusable SQL Views

```text
vw_order_analytics
vw_product_performance
vw_customer_performance
vw_delivery_performance
vw_marketing_performance
```

---

## 📌 Important Metric Definition

The dashboard's **Average Delivery Time of 19.43 minutes** is calculated using:

```text
Actual Delivery Time - Order Time
```

This is different from the `delivery_time_minutes` field in the delivery-performance dataset, which represents the difference between **actual delivery time and promised delivery time**.

---

## 🚀 How to Run the Project

### 1. Clone the repository

```bash
git clone https://github.com/kunaltopare01/blinkit-orders-analytics-dashboard.git
```

### 2. Navigate to the project folder

```bash
cd blinkit-orders-analytics-dashboard
```

### 3. Set up MySQL

Install **MySQL 8+** and create the required database/tables using:

```text
sql/blinkit_orders_analysis.sql
```

### 4. Load the datasets

Load the corresponding CSV files into the MySQL tables.

### 5. Run the SQL analysis

Execute the KPI queries, analytical queries, and reusable views provided in the SQL file.

### 6. Open the Power BI dashboard

Open:

```text
dashboard/Blinkit_Orders_Analytics_Dashboard.pbix
```

Connect Power BI to the MySQL database or use the prepared analytical views.

---

## 📊 Dashboard Preview

> 📄 **Dashboard Preview:** [Open Full Dashboard PDF](screenshots/dashboard_overview.pdf)

---

## 💡 Key Insights

- The dataset contains **5,000 orders** generating approximately **₹11.01M in revenue**.
- The average order value is approximately **₹2,201.86**.
- The overall on-time delivery rate is **69.40%**.
- The average delivery time is approximately **19.43 minutes**.
- The dataset contains **2,500 customers** across different customer segments.
- Product analysis covers **268 products** and more than **10K units sold**.
- Product-level analysis highlights differences in revenue, selling price, and margin across categories.
- Delivery analysis compares promised and actual delivery performance and examines the relationship between distance and delivery time.
- Marketing analysis compares channel-level spending with generated revenue and ROAS.

---

## 📚 Learning Outcomes

Through this project, I practiced:

- SQL-based business analysis
- Relational data analysis
- Data-quality validation
- KPI development
- Power BI dashboard design
- Customer analytics
- Sales and revenue analytics
- Product performance analysis
- Delivery and operational analytics
- Marketing performance analysis
- Creating reusable SQL views for BI reporting

---

## 👤 Author

**Kunal Topare**

Aspiring Data Analyst

**Skills:** SQL | MySQL | Power BI | Python | Pandas | Data Analytics | Data Visualization | Business Intelligence

---

## 🔗 Project

**Blinkit Orders Analytics Dashboard**

Built as a portfolio project to demonstrate practical **SQL + Power BI + Business Analytics** skills.
