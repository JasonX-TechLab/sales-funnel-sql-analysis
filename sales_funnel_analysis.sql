SELECT COUNT(*) 
FROM `rising-solstice-426013-q7.sql_practice.user_events` 


-- define the sales funnel and the different stages (last 30 days relative to latest date in dataset)
WITH latest AS (
  SELECT MAX(event_date) AS latest_event_ts
  FROM `rising-solstice-426013-q7.sql_practice.user_events`
),

funnel_stages AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END)AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase

  FROM `rising-solstice-426013-q7.sql_practice.user_events` 
  
  CROSS JOIN latest
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE(latest.latest_event_ts), INTERVAL 30 DAY))
)

SELECT * FROM funnel_stages

-- conversion rate through the funnel (last 30 days relative to latest date in dataset)

WITH latest AS (
  SELECT MAX(event_date) AS latest_event_ts
  FROM `rising-solstice-426013-q7.sql_practice.user_events`
),
funnel_stages AS (
  SELECT 
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS stage_1_views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS stage_2_cart,
    COUNT(DISTINCT CASE WHEN event_type = 'checkout_start' THEN user_id END) AS stage_3_checkout,
    COUNT(DISTINCT CASE WHEN event_type = 'payment_info' THEN user_id END) AS stage_4_payment,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS stage_5_purchase
  FROM `rising-solstice-426013-q7.sql_practice.user_events`
  CROSS JOIN latest
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE(latest.latest_event_ts), INTERVAL 30 DAY))
)

SELECT
  stage_1_views,
  stage_2_cart,
  ROUND(SAFE_DIVIDE(stage_2_cart * 100, stage_1_views), 2) AS view_to_cart_rate_pct,

  stage_3_checkout,
  ROUND(SAFE_DIVIDE(stage_3_checkout * 100, stage_2_cart), 2) AS cart_to_checkout_rate_pct,
  
  stage_4_payment,
  ROUND(SAFE_DIVIDE(stage_4_payment * 100, stage_3_checkout), 2) AS checkout_to_payment_rate_pct,

  stage_5_purchase,
  ROUND(SAFE_DIVIDE(stage_5_purchase * 100, stage_4_payment), 2) AS payment_to_purchase_rate_pct,

  ROUND(SAFE_DIVIDE(stage_5_purchase * 100, stage_1_views), 2) AS overall_conversion_rate_pct

FROM funnel_stages;



-- funnel performance by traffic source (last 30 days relative to latest dataset date)

WITH latest AS (
  SELECT MAX(event_date) AS latest_event_ts
  FROM `rising-solstice-426013-q7.sql_practice.user_events`
),

source_funnel AS (
  SELECT
    traffic_source,
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS views,
    COUNT(DISTINCT CASE WHEN event_type = 'add_to_cart' THEN user_id END) AS carts,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS purchases
  FROM `rising-solstice-426013-q7.sql_practice.user_events`
  CROSS JOIN latest
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE(latest.latest_event_ts), INTERVAL 30 DAY))
  GROUP BY traffic_source
)

SELECT
  traffic_source,
  views,
  carts,
  purchases,
  ROUND(SAFE_DIVIDE(carts * 100, views), 2) AS cart_conversion_rate_pct,
  ROUND(SAFE_DIVIDE(purchases * 100, views), 2) AS purchase_conversion_rate_pct,
  ROUND(SAFE_DIVIDE(purchases * 100, carts), 2) AS cart_to_purchase_conversion_rate_pct
FROM source_funnel
ORDER BY purchases DESC;

-- time to conversion analysis (last 30 days relative to latest dataset date)

WITH latest AS (
  SELECT MAX(event_date) AS latest_event_ts
  FROM `rising-solstice-426013-q7.sql_practice.user_events`
),

user_journey AS (
  SELECT
  user_id,
    MIN(CASE WHEN event_type = 'page_view' THEN event_date END) AS view_time,
    MIN(CASE WHEN event_type = 'add_to_cart' THEN event_date END)AS cart_time,
    MIN(CASE WHEN event_type = 'purchase' THEN event_date END) AS purchase_time

  FROM `rising-solstice-426013-q7.sql_practice.user_events` 

  CROSS JOIN latest
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE(latest.latest_event_ts), INTERVAL 30 DAY))
  GROUP BY user_id
  HAVING purchase_time IS NOT NULL

) 

SELECT
  COUNT(*) AS converted_users,
  ROUND(AVG(TIMESTAMP_DIFF(cart_time, view_time, MINUTE)),2) AS avg_view_to_cart_minutes,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, cart_time, MINUTE)),2) AS avg_cart_to_purchase_minutes,
  ROUND(AVG(TIMESTAMP_DIFF(purchase_time, view_time, MINUTE)),2) AS avg_total_journey_minutes,

FROM user_journey

--- revenue funnel analysis (last 30 days relative to latest dataset date)

WITH latest AS (
  SELECT MAX(event_date) AS latest_event_ts
  FROM `rising-solstice-426013-q7.sql_practice.user_events`
),

funnel_revenue AS (
  SELECT
    COUNT(DISTINCT CASE WHEN event_type = 'page_view' THEN user_id END) AS total_visitors,
    COUNT(DISTINCT CASE WHEN event_type = 'purchase' THEN user_id END) AS total_buyers,
    SUM(CASE WHEN event_type = 'purchase' THEN amount END) AS total_revenue,
    COUNT(CASE WHEN event_type = 'purchase' THEN 1 END) AS total_orders,

  FROM `rising-solstice-426013-q7.sql_practice.user_events` 

  CROSS JOIN latest
  WHERE event_date >= TIMESTAMP(DATE_SUB(DATE(latest.latest_event_ts), INTERVAL 30 DAY))
)

SELECT
  total_visitors,
  total_buyers,
  total_orders,
  ROUND(total_revenue) AS total_revenue, 

  ROUND(total_revenue / total_orders) AS avg_order_value,
  ROUND(total_revenue / total_orders) AS revenue_per_buyer,
  ROUND(total_revenue / total_visitors) AS revenue_per_visitors

FROM funnel_revenue


