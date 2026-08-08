/*============================================================
				BUSINESS ANALYSIS USING SQL
==============================================================

PROJECT
Multi-Channel Profitability & Customer Growth Analysis

FILE
03_Business_Analysis.sql

PURPOSE
Answer the project's key business questions through
SQL-based business analysis of the prepared retail dataset.
The insights generated from this analysis directly support
the Power BI dashboard, business findings, and strategic
recommendations presented throughout the case study.

============================================================*/

/*============================================================
                     Analytical Dataset
==============================================================

Dataset
retail_sales_clean_final

This dataset represents the final cleaned and standardized
analytical layer produced through the data preparation
pipeline. All business analyses within this file are
performed using this analysis-ready dataset.

============================================================*/

/*============================================================
                     Executive Performance Overview 
==============================================================

Objective

Evaluate overall business performance by examining revenue,
profitability, customer activity, and business growth over
time. This section establishes the business context before
investigating individual areas of performance.

============================================================*/


/*------------------------------------------------------------
 Business Question
1.How has overall business performance evolved over time?

------------------------------------------------------------*/

SELECT
    YEAR(order_date) AS year,
    MONTH(order_date) AS month,

    SUM(revenue) AS total_revenue,

    SUM(revenue - cogs - shipping_cost) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin,

    COUNT(DISTINCT `order id`) AS total_orders

FROM retail_sales_clean_final

GROUP BY
    YEAR(order_date),
    MONTH(order_date)

ORDER BY
    year,
    month;


/*----------------------------------------------------------------------------------------------------------------------
Business Question
2. Which months generated the strongest financial performance?

Business Purpose

Compare monthly financial performance to identify the highest-performing periods based on revenue, profitability,
and business activity.

----------------------------------------------------------------------------------------------------------------------*/

 SELECT 
    YEAR(order_date) AS year,
    MONTHNAME(order_date) AS month_name,

	ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    COUNT(DISTINCT `order id`) AS total_orders

FROM retail_sales_clean_final

GROUP BY 
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date)

ORDER BY total_revenue DESC;
  

/*----------------------------------------------------------------------------------------------------------------------
Business Question
3. Are there recurring seasonal patterns in business performance?

Business Purpose

Evaluate monthly revenue, profitability, customer demand, discount behavior, and shipping costs to identify seasonal
patterns that may influence business performance throughout the year.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,

    ROUND(SUM(revenue),2) AS total_revenue,
    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,
    

    COUNT(DISTINCT `order id`) AS total_orders,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost

FROM retail_sales_clean_final

GROUP BY 
    MONTH(order_date),
    MONTHNAME(order_date)

ORDER BY month_number;


/*----------------------------------------------------------------------------------------------------------------------
 Business Question
4. How stable is profitability throughout the reporting period?

Business Purpose

Assess monthly profit performance, profit margins, shipping costs, and discount levels to evaluate the consistency and
sustainability of business profitability over time.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    YEAR(order_date) AS year,
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct

FROM retail_sales_clean_final

GROUP BY 
    YEAR(order_date),
    MONTH(order_date),
    MONTHNAME(order_date)

ORDER BY 
    year,
    month_number;


/*----------------------------------------------------------------------------------------------------------------------
 Business Question
5.How do seasonal trends influence sales and profitability?

Business Purpose

Investigate the relationship between seasonal demand, profitability, discounts, shipping costs, and product returns to
understand how seasonal patterns impact overall business performance.

----------------------------------------------------------------------------------------------------------------------*/

 
    SELECT 
    MONTH(order_date) AS month_number,
    MONTHNAME(order_date) AS month_name,
    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,


    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    ROUND(
        (SUM(returned) / COUNT(`order id`)) * 100,
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

GROUP BY 
    MONTH(order_date),
    MONTHNAME(order_date)

ORDER BY month_number;



/*======================================================================================================================
                                         PROFITABILITY INTELLIGENCE
========================================================================================================================

Objective

Evaluate the financial performance of the business by identifying key profit drivers, margin risks, discount impact,
shipping cost efficiency, and operational performance across products, categories, sales channels, and business locations.
This section helps determine where profitability is strongest, where margins are under pressure, and which areas present
opportunities for improving overall financial performance.


/*----------------------------------------------------------------------------------------------------------------------

Business Question
1. Which categories make the most profit?

Business Purpose

Compare financial performance across product categories by evaluating revenue, profit, profit margin, discount levels,
shipping costs, and order volume to identify the categories contributing most to overall profitability.

----------------------------------------------------------------------------------------------------------------------*/

 SELECT 
    category,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    COUNT(DISTINCT `order id`) AS total_orders

FROM retail_sales_clean_final

GROUP BY category

ORDER BY total_profit DESC;
 
 
 /*----------------------------------------------------------------------------------------------------------------------

 Business Question
2. Which products hurt margins?
Business Purpose

Evaluate product subcategories to identify those generating the lowest profit margins while considering revenue,
discount levels, shipping costs, and return rates that may be reducing overall profitability.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    subcategory,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    ROUND(
        (SUM(returned) / COUNT(`order id`)) * 100,
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

GROUP BY subcategory

ORDER BY profit_margin_pct ASC;
 
 
 /*----------------------------------------------------------------------------------------------------------------------

Business Question
3. Are discounts reducing profitability?

Business Purpose

Assess the relationship between discount levels and financial performance to understand how discounting strategies
influence revenue, profitability, and overall business margins.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    CASE
        WHEN discount_percent = 0 THEN 'No Discount'
        WHEN discount_percent <= 10 THEN 'Low Discount'
        WHEN discount_percent <= 20 THEN 'Medium Discount'
        ELSE 'High Discount'
    END AS discount_group,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    COUNT(DISTINCT `order id`) AS total_orders

FROM retail_sales_clean_final

GROUP BY discount_group

ORDER BY avg_discount_pct;

/*----------------------------------------------------------------------------------------------------------------------

Business Question
4. Is shipping cost becoming a problem?

Business Purpose

Analyze shipping cost performance across sales channels to evaluate its impact on revenue, profitability, and overall
operational efficiency.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    `sales channel`,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(SUM(shipping_cost),2) AS total_shipping_cost,

    ROUND(
        AVG(shipping_cost),
        2
    ) AS avg_shipping_cost,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS shipping_cost_pct_of_revenue,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_percent

FROM retail_sales_clean_final

GROUP BY `sales channel`

ORDER BY shipping_cost_pct_of_revenue DESC;
 
 
 /*----------------------------------------------------------------------------------------------------------------------
 
Business Question
5. Are high-revenue products also highly profitable?

Business Purpose

Compare revenue generation and profitability across product subcategories to determine whether the highest-selling
products also contribute strong financial returns.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    subcategory,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost

FROM retail_sales_clean_final

GROUP BY subcategory

ORDER BY total_revenue DESC;

/*----------------------------------------------------------------------------------------------------------------------

Business Question
6. Which business areas are operationally efficient vs operationally risky?

Business Purpose

Evaluate store performance by comparing revenue, profit, profit margins, discount levels, shipping costs, return rates,
and order volume to identify locations demonstrating strong operational efficiency and those requiring business attention.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    store,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    ROUND(
        (SUM(returned) / COUNT(`order id`)) * 100,
        2
    ) AS return_rate_pct,

    COUNT(DISTINCT `order id`) AS total_orders

FROM retail_sales_clean_final

GROUP BY store

ORDER BY profit_margin_pct DESC;
 

/*======================================================================================================================
                                          CUSTOMER INTELLIGENCE
========================================================================================================================

Objective

Evaluate customer performance by analyzing revenue contribution, profitability, and customer satisfaction across
different customer segments. This section identifies the customer groups that generate the greatest business value
and examines how customer ratings relate to financial performance, supporting more informed customer-focused
business decisions.


======================================================================================================================*/

/*----------------------------------------------------------------------------------------------------------------------

Business Question
1. Which customer segments generate the highest revenue and profit?

Business Purpose

Compare customer segments using revenue, profit, profit margin, order volume, and supporting financial metrics to
identify the customer groups contributing the greatest overall business value.

----------------------------------------------------------------------------------------------------------------------*/

 SELECT 
    `customer segment`,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    COUNT(DISTINCT `order id`) AS total_orders,

    ROUND(
        AVG(revenue),
        2
    ) AS avg_order_value,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost

FROM retail_sales_clean_final

GROUP BY `customer segment`

ORDER BY total_profit DESC;
 
 /*----------------------------------------------------------------------------------------------------------------------

Business Question
2. Are customer ratings associated with profitability?

Business Purpose

Analyze business performance across different customer rating levels to evaluate whether higher customer satisfaction
is associated with stronger financial performance and profitability.

----------------------------------------------------------------------------------------------------------------------*/

SELECT 
    customer_rating,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(discount_percent),2) AS avg_discount_percent,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    COUNT(DISTINCT `order id`) AS total_orders

FROM retail_sales_clean_final

GROUP BY customer_rating

ORDER BY customer_rating;

/*----------------------------------------------------------------------------------------------------------------------

Business Question
3. Which customer segments provide the best balance between business scale and profitability?

Business Purpose

Compare customer segments using both business scale and profitability metrics to identify customer groups that generate
strong revenue while maintaining healthy profit margins. This analysis helps distinguish high-volume customer segments
from those delivering sustainable financial performance.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    `Customer Segment`,

    COUNT(DISTINCT `Order ID`) AS total_orders,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(revenue), 2) AS avg_order_value,

    ROUND(AVG(discount_percent), 2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,

    ROUND(
        (SUM(returned) / COUNT(`Order ID`)) * 100,
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

GROUP BY `Customer Segment`

ORDER BY
    total_profit DESC,
    profit_margin_pct DESC,
    total_revenue DESC;


/*======================================================================================================================
                                        OPERATIONAL INTELLIGENCE
========================================================================================================================

Objective

Evaluate operational performance across stores, sales channels, shipping methods, and product returns to identify
operational risks, efficiency gaps, and improvement opportunities. This analysis helps assess how operational
activities influence profitability, customer experience, and overall business performance.

======================================================================================================================*/


/*----------------------------------------------------------------------------------------------------------------------

Business Question

1. Which products experience the highest return rates?

Business Purpose

Evaluate product return performance across categories and subcategories to identify products generating the highest
return rates and assess their impact on revenue and profitability.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    Category,
    Subcategory,

    COUNT(DISTINCT `Order ID`) AS total_orders,

    SUM(
        CASE
            WHEN returned = 1 THEN 1
            ELSE 0
        END
    ) AS returned_orders,

    ROUND(
        (
            SUM(
                CASE
                    WHEN returned = 1 THEN 1
                    ELSE 0
                END
            ) * 100.0
        ) / COUNT(DISTINCT `Order ID`),
        2
    ) AS return_rate_pct,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit

FROM retail_sales_clean_final

GROUP BY
    Category,
    Subcategory

ORDER BY return_rate_pct DESC;


/*----------------------------------------------------------------------------------------------------------------------

Business Question
2. Which stores under performed ?

Business Purpose

Compare operational performance across stores and sales channels using revenue, profitability, order volume,
customer ratings, shipping costs, and discount levels to identify high-performing and underperforming business
operations.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    `Store`,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    COUNT(DISTINCT `Order ID`) AS total_orders,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    ROUND(AVG(discount_percent),2) AS avg_discount_pct,

    ROUND(AVG(customer_rating),2) AS avg_customer_rating

FROM retail_sales_clean_final

GROUP BY `Store`

ORDER BY total_profit ASC;

/*----------------------------------------------------------------------------------------------------------------------

Business Question

3. Which shipping methods create the greatest operational cost?

Business Purpose

Evaluate shipping modes by comparing shipping costs, shipping cost ratios, revenue, profitability, and operational
efficiency to identify fulfillment methods placing the greatest pressure on business performance.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    `Shipping Mode`,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(SUM(shipping_cost),2) AS total_shipping_cost,

    ROUND(AVG(shipping_cost),2) AS avg_shipping_cost,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(shipping_cost) / SUM(revenue)
        ) * 100,
        2
    ) AS shipping_cost_ratio_pct,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_clean_final

GROUP BY `Shipping Mode`

ORDER BY shipping_cost_ratio_pct DESC;

/*----------------------------------------------------------------------------------------------------------------------

Business Question
4. Which operational areas present the highest business risk?

Business Purpose

Assess operational risk across combinations of stores, sales channels, and shipping methods by comparing profitability,
return rates, customer ratings, shipping costs, and discount levels to identify operational areas requiring business
attention.

----------------------------------------------------------------------------------------------------------------------*/
SELECT
    store,
    `sales channel`,
    `shipping mode`,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,

    ROUND(AVG(discount_percent), 2) AS avg_discount_pct,

    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,

    ROUND(
        (
            SUM(
                CASE
                    WHEN returned = 1 THEN quantity
                    ELSE 0
                END
            ) * 100.0
        ) / SUM(quantity),
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

WHERE store IS NOT NULL

GROUP BY
    store,
    `sales channel`,
    `shipping mode`

ORDER BY profit_margin_pct ASC;



/*======================================================================================================================

REGIONAL & CHANNEL INTELLIGENCE

Business Objective

Evaluate regional and sales channel performance to understand where revenue,
profitability, and customer demand are strongest. This analysis helps identify
high-performing markets, monitor regional profitability trends, compare sales
channel effectiveness, and distinguish sustainable growth opportunities from
operational risk.

Note

The source dataset stores the geographical dimension as "Region". Throughout the
Power BI dashboard and case study, this dimension is presented as "Sales Area"
to improve business readability. Both terms refer to the same business concept.

======================================================================================================================*/

/*----------------------------------------------------------------------------------------------------------------------

Business Question
1. Which regions perform strongly in sales and profitability, and what products
   drive demand within those regions?

Business Purpose

Identify high-performing regions by evaluating revenue, profit, profit margin,
and product demand to support regional growth and inventory planning.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    region,
    category,
    subcategory,

    COUNT(DISTINCT `Order ID`) AS total_orders,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(
        (
            SUM(
                CASE
                    WHEN returned = 1 THEN quantity
                    ELSE 0
                END
            ) * 100.0
        ) / SUM(quantity),
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

WHERE region IS NOT NULL

GROUP BY
    region,
    category,
    subcategory

ORDER BY total_revenue DESC;

/*----------------------------------------------------------------------------------------------------------------------

Business Question
2. How has regional profitability changed over time?

Business Purpose

Track monthly profitability trends across regions to evaluate performance
consistency and identify emerging growth or declining market areas.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    YEAR(order_date) AS order_year,
    MONTH(order_date) AS order_month,
    region,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_clean_final

WHERE region IS NOT NULL

GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    region

ORDER BY
    order_year,
    order_month,
    total_profit DESC;

/*----------------------------------------------------------------------------------------------------------------------

Business Question

3. Which sales channels contribute the healthiest profitability and customer
   performance?

Business Purpose

Compare sales channels using profitability, customer satisfaction, discounts,
shipping costs, and return rates to identify the most efficient revenue
channels.

----------------------------------------------------------------------------------------------------------------------*/

 SELECT
    `sales channel`,

    COUNT(DISTINCT `Order ID`) AS total_orders,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,

    ROUND(AVG(discount_percent), 2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,

    ROUND(
        (
            SUM(
                CASE
                    WHEN returned = 1 THEN quantity
                    ELSE 0
                END
            ) * 100.0
        ) / SUM(quantity),
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

GROUP BY `sales channel`

ORDER BY profit_margin_pct DESC; 

/*----------------------------------------------------------------------------------------------------------------------

Business Question
4. Which sales channels generate sustainable growth versus operational risk?

Business Purpose

Evaluate whether revenue growth is supported by healthy profit margins,
controlled operational costs, and low return rates to distinguish sustainable
business performance from high-risk growth.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    YEAR(order_date) AS sales_year,
    MONTH(order_date) AS sales_month,
    `Sales Channel`,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    COUNT(DISTINCT `Order ID`) AS total_orders

FROM retail_sales_clean_final

GROUP BY
    YEAR(order_date),
    MONTH(order_date),
    `Sales Channel`

ORDER BY
    sales_year,
    sales_month,
    total_profit DESC;
    
    
    
 /*======================================================================================================================

PRODUCT PERFORMANCE ANALYSIS

Business Objective

Evaluate product and category performance to identify demand patterns,
profitability drivers, return behavior, and operational efficiency. This
analysis supports product portfolio optimization, inventory planning, and
strategic merchandising decisions by highlighting products that contribute
sustainable business value and those requiring operational attention.

======================================================================================================================*/   
    
/*----------------------------------------------------------------------------------------------------------------------

Business Question
1. Which products are fast-moving versus slow-moving, and how should the business
   respond strategically?

Business Purpose

Measure product demand using order volume, quantity sold, revenue, and
profitability to identify high-demand products for growth opportunities and
low-demand products that may require inventory or merchandising optimization.

----------------------------------------------------------------------------------------------------------------------*/    
    
 SELECT
    category,
    subcategory,

    COUNT(DISTINCT `Order ID`) AS total_orders,

    SUM(quantity) AS total_quantity_sold,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_clean_final

GROUP BY
    category,
    subcategory

ORDER BY total_quantity_sold DESC;    
    
 /*----------------------------------------------------------------------------------------------------------------------

Business Question
2. Which products or categories experience the highest return rates, and what
   patterns may contribute to those returns?

Business Purpose

Analyze product return behavior alongside profitability, customer ratings,
discount levels, and shipping costs to identify products that may require
quality improvements, pricing adjustments, or operational review.

----------------------------------------------------------------------------------------------------------------------*/   
    
SELECT
    category,
    subcategory,

    SUM(quantity) AS total_quantity_sold,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(AVG(discount_percent), 2) AS avg_discount_pct,

    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,

    ROUND(AVG(customer_rating), 2) AS avg_customer_rating,

    ROUND(
        (
            SUM(
                CASE
                    WHEN returned = 1 THEN quantity
                    ELSE 0
                END
            ) * 100.0
        ) / SUM(quantity),
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

GROUP BY
    category,
    subcategory

ORDER BY return_rate_pct DESC;

/*----------------------------------------------------------------------------------------------------------------------

Business Question
3. Which products deliver the strongest balance between sales volume and profitability?

Business Purpose

Identify products that combine strong customer demand with healthy profitability.
This analysis helps distinguish products that not only generate high sales volume
but also contribute meaningful profit, supporting product portfolio optimization,
inventory planning, and long-term business growth.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    category,
    subcategory,

    COUNT(DISTINCT `Order ID`) AS total_orders,

    SUM(quantity) AS total_quantity_sold,

    ROUND(SUM(revenue),2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct

FROM retail_sales_clean_final

GROUP BY
    category,
    subcategory

ORDER BY
    total_profit DESC,
    total_quantity_sold DESC;

/*----------------------------------------------------------------------------------------------------------------------

Business Question
4. Which products appear operationally efficient versus operationally expensive?

Business Purpose

Compare products using shipping costs, profitability, discount levels, and
return rates to identify products with efficient operational performance and
those generating higher fulfillment costs or operational pressure.

----------------------------------------------------------------------------------------------------------------------*/

SELECT
    category,
    subcategory,

    ROUND(SUM(revenue), 2) AS total_revenue,

    ROUND(
        SUM(revenue - cogs - shipping_cost),
        2
    ) AS total_profit,

    ROUND(
        (
            SUM(revenue - cogs - shipping_cost)
            / SUM(revenue)
        ) * 100,
        2
    ) AS profit_margin_pct,

    ROUND(AVG(shipping_cost), 2) AS avg_shipping_cost,

    ROUND(AVG(discount_percent), 2) AS avg_discount_pct,

    ROUND(
        (
            SUM(
                CASE
                    WHEN returned = 1 THEN quantity
                    ELSE 0
                END
            ) * 100.0
        ) / SUM(quantity),
        2
    ) AS return_rate_pct

FROM retail_sales_clean_final

GROUP BY
    category,
    subcategory

ORDER BY
    avg_shipping_cost DESC,
    return_rate_pct DESC;



    