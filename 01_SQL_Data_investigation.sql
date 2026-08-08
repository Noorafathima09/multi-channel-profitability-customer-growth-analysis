/*==========================================================
           DATA INVESTIGATION & AUDIT USING SQL 
============================================================

  PROJECT:
  Multi-Channel Retail Business Intelligence

  FILE:
  01_Data_Investigation_Audit.sql

  PURPOSE:
  This script documents the SQL-based data investigation and
  quality assessment performed before data preparation.

  The objective is to evaluate the structural integrity,
  completeness, consistency, and business reliability of the
  raw transactional dataset prior to analytical modeling.

============================================================*/

/*============================================================
  01 | Dataset Overview
==============================================================

Objective:
Understand the overall size of the raw transactional dataset
before beginning data quality assessment.

============================================================*/

SELECT COUNT(*) AS total_rows
FROM retail_sales;

/*============================================================
  02 | Missing Value Assessment
==============================================================

Objective:
Assess the completeness of the raw dataset by identifying
missing and blank values across all business attributes.
This assessment establishes the initial data quality baseline
before investigating the underlying causes of missing values.

============================================================*/

SELECT
    SUM(CASE WHEN `Order ID` IS NULL OR TRIM(`Order ID`) = '' THEN 1 ELSE 0 END) AS missing_order_id,

    SUM(CASE WHEN `Order Date` IS NULL THEN 1 ELSE 0 END) AS missing_order_date,

    SUM(CASE WHEN Store IS NULL OR TRIM(Store) = '' THEN 1 ELSE 0 END) AS missing_store,

    SUM(CASE WHEN Region IS NULL OR TRIM(Region) = '' THEN 1 ELSE 0 END) AS missing_region,

    SUM(CASE WHEN `Customer Segment` IS NULL OR TRIM(`Customer Segment`) = '' THEN 1 ELSE 0 END) AS missing_customer_segment,

    SUM(CASE WHEN `Sales Channel` IS NULL OR TRIM(`Sales Channel`) = '' THEN 1 ELSE 0 END) AS missing_sales_channel,

    SUM(CASE WHEN Category IS NULL OR TRIM(Category) = '' THEN 1 ELSE 0 END) AS missing_category,

    SUM(CASE WHEN Subcategory IS NULL OR TRIM(Subcategory) = '' THEN 1 ELSE 0 END) AS missing_subcategory,

    SUM(CASE WHEN SKU IS NULL OR TRIM(SKU) = '' THEN 1 ELSE 0 END) AS missing_sku,

    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS missing_quantity,

    SUM(CASE WHEN `Unit Price` IS NULL THEN 1 ELSE 0 END) AS missing_unit_price,

    SUM(CASE WHEN `Discount %` IS NULL OR TRIM(`Discount %`) = '' THEN 1 ELSE 0 END) AS missing_discount,

    SUM(CASE WHEN Revenue IS NULL THEN 1 ELSE 0 END) AS missing_revenue,

    SUM(CASE WHEN COGS IS NULL THEN 1 ELSE 0 END) AS missing_cogs,

    SUM(CASE WHEN `Shipping Cost` IS NULL THEN 1 ELSE 0 END) AS missing_shipping_cost,

    SUM(CASE WHEN Returned IS NULL OR TRIM(Returned) = '' THEN 1 ELSE 0 END) AS missing_returned,

    SUM(CASE WHEN `Customer Rating` IS NULL OR TRIM(`Customer Rating`) = '' THEN 1 ELSE 0 END) AS missing_customer_rating,

    SUM(CASE WHEN `Payment Method` IS NULL OR TRIM(`Payment Method`) = '' THEN 1 ELSE 0 END) AS missing_payment_method,

    SUM(CASE WHEN `Shipping Mode` IS NULL OR TRIM(`Shipping Mode`) = '' THEN 1 ELSE 0 END) AS missing_shipping_mode

FROM retail_sales;


/*============================================================
  03 | Missing Value Pattern Investigation
==============================================================

Objective:
Investigate whether missing values occur randomly or follow
a consistent pattern that may indicate structural issues,
placeholder records, or systematic data quality problems.

============================================================*/

SELECT *
FROM retail_sales
WHERE
    `Sales Channel` IS NULL OR TRIM(`Sales Channel`) = ''
    OR Category IS NULL OR TRIM(Category) = ''
    OR Subcategory IS NULL OR TRIM(Subcategory) = ''
    OR SKU IS NULL OR TRIM(SKU) = ''
    OR Returned IS NULL OR TRIM(Returned) = ''
    OR `Payment Method` IS NULL OR TRIM(`Payment Method`) = ''
    OR `Shipping Mode` IS NULL OR TRIM(`Shipping Mode`) = '';


/*============================================================
  04 | Duplicate Transaction Assessment
==============================================================

Objective:
Identify exact duplicate transaction records that may
artificially inflate business metrics and affect the
accuracy of downstream analysis.

============================================================*/

SELECT
    `Order ID`,
    `Order Date`,
    Store,
    Region,
    `Customer Segment`,
    `Sales Channel`,
    Category,
    Subcategory,
    SKU,
    Quantity,
    `Unit Price`,
    `Discount %`,
    Revenue,
    COGS,
    `Shipping Cost`,
    Returned,
    `Customer Rating`,
    `Payment Method`,
    `Shipping Mode`,
    COUNT(*) AS duplicate_count

FROM retail_sales

GROUP BY
    `Order ID`,
    `Order Date`,
    Store,
    Region,
    `Customer Segment`,
    `Sales Channel`,
    Category,
    Subcategory,
    SKU,
    Quantity,
    `Unit Price`,
    `Discount %`,
    Revenue,
    COGS,
    `Shipping Cost`,
    Returned,
    `Customer Rating`,
    `Payment Method`,
    `Shipping Mode`

HAVING COUNT(*) > 1;

/*============================================================
  05 | Text Standardization Audit
==============================================================

Objective:
Review categorical business attributes for inconsistent text
representations, including variations in letter casing,
trailing spaces, placeholder values, and blank entries that
could fragment grouping and aggregation during analysis.

============================================================*/


/* Store */

SELECT DISTINCT Store
FROM retail_sales
ORDER BY Store;


/* Region */

SELECT DISTINCT Region
FROM retail_sales
ORDER BY Region;


/* Customer Segment */

SELECT DISTINCT `Customer Segment`
FROM retail_sales
ORDER BY `Customer Segment`;


/* Sales Channel */

SELECT DISTINCT `Sales Channel`
FROM retail_sales
ORDER BY `Sales Channel`;


/* Category */

SELECT DISTINCT Category
FROM retail_sales
ORDER BY Category;


/* Subcategory */

SELECT DISTINCT Subcategory
FROM retail_sales
ORDER BY Subcategory;


/* Payment Method */

SELECT DISTINCT `Payment Method`
FROM retail_sales
ORDER BY `Payment Method`;


/* Shipping Mode */

SELECT DISTINCT `Shipping Mode`
FROM retail_sales
ORDER BY `Shipping Mode`;


/*============================================================
  06 | Financial & Business Rule Validation
==============================================================

Objective:
Validate the financial integrity and business logic of key
transactional fields to ensure that revenue, discounts, and
profit-related calculations accurately represent business
activity before analytical reporting.

============================================================*/


/* Discount Value Assessment */

SELECT DISTINCT `Discount %`
FROM retail_sales
ORDER BY `Discount %`;


/* Blank Discount Investigation */

SELECT *
FROM retail_sales
WHERE `Discount %` = '';


/* Revenue Calculation Validation */

SELECT *
FROM retail_sales
WHERE ABS(
        Revenue -
        (Quantity * `Unit Price` * (1 - (`Discount %` / 100)))
      ) > 1
  AND `Order ID` <> 'TOTAL'
  AND `Discount %` <> '';


/* Profit Calculation Validation */

SELECT
    `Order ID`,
    Revenue,
    COGS,

    ROUND(Revenue - COGS, 2) AS calculated_profit,

    ROUND(
        ((Revenue - COGS) / Revenue) * 100,
        2
    ) AS calculated_profit_margin

FROM retail_sales
WHERE `Order ID` <> 'TOTAL'
LIMIT 20;


/* Missing Discount Assessment */

SELECT
    `Order ID`,
    Quantity,
    `Unit Price`,
    `Discount %`,
    Revenue,

    ROUND(
        Quantity * `Unit Price`,
        2
    ) AS expected_revenue_without_discount

FROM retail_sales
WHERE `Discount %` = ''
AND `Order ID` <> 'TOTAL'
LIMIT 20;


/* Implied Discount Validation */

SELECT
    `Order ID`,
    Quantity,
    `Unit Price`,
    Revenue,

    ROUND(
        (
            1 - (
                Revenue /
                (Quantity * `Unit Price`)
            )
        ) * 100,
        2
    ) AS implied_discount_percent

FROM retail_sales
WHERE `Discount %` = ''
AND `Order ID` <> 'TOTAL'
LIMIT 20;


/*============================================================
  07 | Numerical Integrity Assessment
==============================================================

Objective:
Assess numerical fields for invalid, negative, or zero values
that could indicate data quality issues or compromise the
accuracy of business analysis.

============================================================*/


/* Invalid Value Assessment */

SELECT
    SUM(CASE WHEN Quantity <= 0 THEN 1 ELSE 0 END) AS invalid_quantity,

    SUM(CASE WHEN `Unit Price` <= 0 THEN 1 ELSE 0 END) AS invalid_unit_price,

    SUM(CASE WHEN Revenue <= 0 THEN 1 ELSE 0 END) AS invalid_revenue,

    SUM(CASE WHEN COGS <= 0 THEN 1 ELSE 0 END) AS invalid_cogs,

    SUM(CASE WHEN `Shipping Cost` < 0 THEN 1 ELSE 0 END) AS invalid_shipping_cost,

    SUM(
        CASE
            WHEN `Customer Rating` < 1
              OR `Customer Rating` > 5
            THEN 1
            ELSE 0
        END
    ) AS invalid_customer_rating

FROM retail_sales
WHERE `Order ID` <> 'TOTAL';


/* Negative & Zero Value Assessment */

SELECT
    SUM(CASE WHEN Quantity < 0 THEN 1 ELSE 0 END) AS negative_quantity,
    SUM(CASE WHEN Quantity = 0 THEN 1 ELSE 0 END) AS zero_quantity,

    SUM(CASE WHEN `Unit Price` < 0 THEN 1 ELSE 0 END) AS negative_unit_price,
    SUM(CASE WHEN `Unit Price` = 0 THEN 1 ELSE 0 END) AS zero_unit_price,

    SUM(CASE WHEN Revenue < 0 THEN 1 ELSE 0 END) AS negative_revenue,
    SUM(CASE WHEN Revenue = 0 THEN 1 ELSE 0 END) AS zero_revenue,

    SUM(CASE WHEN COGS < 0 THEN 1 ELSE 0 END) AS negative_cogs,
    SUM(CASE WHEN COGS = 0 THEN 1 ELSE 0 END) AS zero_cogs,

    SUM(CASE WHEN `Shipping Cost` < 0 THEN 1 ELSE 0 END) AS negative_shipping_cost,
    SUM(CASE WHEN `Shipping Cost` = 0 THEN 1 ELSE 0 END) AS zero_shipping_cost

FROM retail_sales
WHERE `Order ID` <> 'TOTAL';


/*============================================================
  08 | Relationship Consistency Validation
==============================================================

Objective:
Verify that related business attributes maintain logical and
consistent relationships throughout the dataset. This
assessment helps identify structural inconsistencies that
could affect business segmentation and reporting accuracy.

============================================================*/


/* Store–Region Relationship */

SELECT DISTINCT
    Store,
    Region
FROM retail_sales
WHERE `Order ID` <> 'TOTAL'
ORDER BY Store, Region;


/* Region Classification Assessment */

SELECT *
FROM retail_sales
WHERE TRIM(LOWER(Region)) = 'online';


/* Online Sales Distribution */

SELECT
    Store,
    `Sales Channel`,
    COUNT(*) AS total_orders
FROM retail_sales
WHERE TRIM(LOWER(Region)) = 'online'
GROUP BY
    Store,
    `Sales Channel`
ORDER BY total_orders DESC;


/*============================================================
  09 | Date Quality Assessment
==============================================================

Objective:
Assess the consistency of the transaction date field by
identifying variations in date formats that may affect
chronological analysis, time intelligence, and dashboard
reporting.

============================================================*/


/* Date Format Assessment */

SELECT
    `Order Date`,

    CASE
        WHEN `Order Date` LIKE '__/__/____' THEN 'Slash Format'
        WHEN `Order Date` LIKE '__-__-____' THEN 'Dash Format'
        WHEN `Order Date` LIKE '____-__-__' THEN 'ISO Format'
        ELSE 'Unknown Format'
    END AS detected_format,

    COUNT(*) AS total_records

FROM retail_sales

GROUP BY
    `Order Date`,
    detected_format

ORDER BY
    detected_format,
    `Order Date`;


/*============================================================
  End of File

  This script documents the SQL-based investigation performed
  to evaluate the quality, consistency, and reliability of
  the raw dataset before data preparation.

============================================================*/








