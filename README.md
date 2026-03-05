# E-Commerce Sales Funnel Analysis (SQL | BigQuery)

This project analyses an e-commerce user event dataset using SQL in Google BigQuery to measure funnel performance, conversion rates, marketing channel effectiveness, time-to-conversion, and revenue metrics.

## Objectives

- Quantify user drop-off across the sales funnel stages
- Compute stage-to-stage and overall conversion rates
- Compare funnel performance by traffic source
- Estimate average time to conversion for converted users
- Summarise revenue outcomes (AOV, revenue per visitor, revenue per buyer)

## Tools & Skills

- Google BigQuery (Standard SQL)
- Common Table Expressions (CTEs)
- Conditional aggregation (`CASE WHEN`)
- De-duplication with `COUNT(DISTINCT ...)`
- Safe calculations with `SAFE_DIVIDE`
- Time interval analysis with `TIMESTAMP_DIFF`

## Funnel Definition

The sales funnel stages are defined using the following event types:

1. `page_view`
2. `add_to_cart`
3. `checkout_start`
4. `payment_info`
5. `purchase`

## Analysis Overview

### 1) Funnel stage counts
Counts unique users at each funnel stage using conditional aggregation.

### 2) Funnel conversion rates
Calculates:
- View → Cart
- Cart → Checkout
- Checkout → Payment
- Payment → Purchase
- Overall conversion rate (View → Purchase)

### 3) Funnel by traffic source
Segments funnel performance by `traffic_source` to compare channel efficiency.

### 4) Time to conversion
Measures time between key milestones (view → cart → purchase) for users who purchased.

### 5) Revenue metrics
Summarises:
- Total revenue
- Total orders
- Average order value (AOV)
- Revenue per buyer
- Revenue per visitor

## Reproducibility Note (Important)

To ensure results remain stable over time, the analysis window is anchored to the **latest date available in the dataset** (using `MAX(event_date)`) rather than `CURRENT_DATE()`.

## Repository Structure

- `sales_funnel_analysis.sql` — all SQL queries used in the analysis
- `data_schema.md` — dataset schema and column descriptions
- `results/` — screenshots of query outputs

## Results (Screenshots)

Add your screenshots into the `results/` folder and reference them here.

Suggested filenames:
- `01_funnel_stage_counts.png`
- `02_funnel_conversion_rates.png`
- `03_traffic_source_conversion_analysis.png`
- `04_time_to_conversion_metrics.png`
- `05_revenue_funnel_metrics.png`

## How to Run

1. Open Google BigQuery
2. Replace the table reference with your table (if different):
   - `rising-solstice-426013-q7.sql_practice.user_events`
3. Run each section of `sales_funnel_analysis.sql` in BigQuery (Standard SQL)

## Notes on Data

The dataset used is an event-based e-commerce dataset for SQL analytics practice.  
The raw dataset is not included in this repository due to potential licensing and redistribution restrictions. See `data_schema.md` for the schema.
