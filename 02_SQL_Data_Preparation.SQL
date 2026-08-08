/*============================================================
         DATA PREPARATION & TRANSFORMATION USING SQL 
==============================================================

 PROJECT :
 Multi-Channel Retail Business Intelligence

 FILE
 02_Data_Preparation_Transformation.sql

 PURPOSE
 Prepare and transform the raw transactional dataset into a
 consistent, analysis-ready dataset suitable for SQL analysis,
 Power BI reporting, and business decision-making.

============================================================*/

/*============================================================
  01 | Create Raw Backup
==============================================================

Objective:
Create a backup copy of the raw dataset before performing
any transformation to preserve the original source data and
support a traceable cleaning workflow.

============================================================*/

CREATE TABLE retail_sales_backup AS
SELECT *
FROM retail_sales.multi_channel_retail;

/*============================================================
  02 | Remove Non-Transactional Records
==============================================================

Objective:
Remove records that do not represent actual business
transactions to ensure subsequent cleaning and analysis are
performed only on valid sales data.

============================================================*/

DELETE FROM retail_sales.multi_channel_retail
WHERE `Order ID` = 'TOTAL';


/*============================================================
  03 | Create Working Dataset
==============================================================

Objective:
Create a dedicated working dataset for all subsequent
cleaning and transformation steps. This preserves the
cleaned raw source while providing an isolated environment
for data preparation.

============================================================*/

CREATE TABLE retail_sales_dedup AS
SELECT DISTINCT *
FROM retail_sales.multi_channel_retail;


/*============================================================
  04 | Standardize Missing Values
==============================================================

Objective:
Replace inconsistent missing value representations with
standard SQL NULL values to establish a consistent foundation
for data transformation and analytical reporting.

============================================================*/


/*------------------------------------------------------------
  Business Dimensions
------------------------------------------------------------*/

/* Store */

UPDATE retail_sales_dedup
SET Store = NULL
WHERE TRIM(LOWER(Store)) IN ('', 'nan');


/* Region */

UPDATE retail_sales_dedup
SET Region = NULL
WHERE TRIM(Region) = '';


/* Customer Segment */

UPDATE retail_sales_dedup
SET `Customer Segment` = NULL
WHERE TRIM(`Customer Segment`) = '';


/* Category */

UPDATE retail_sales_dedup
SET Category = NULL
WHERE TRIM(Category) = '';


/* Subcategory */

UPDATE retail_sales_dedup
SET Subcategory = NULL
WHERE TRIM(Subcategory) = '';


/*------------------------------------------------------------
  Analytical Measures
------------------------------------------------------------*/

/* Discount Percentage */

UPDATE retail_sales_dedup
SET `Discount %` = NULL
WHERE TRIM(`Discount %`) = '';


/* Customer Rating */

UPDATE retail_sales_dedup
SET `Customer Rating` = NULL
WHERE TRIM(`Customer Rating`) = '';


/*============================================================
  05 | Standardize Text Values
==============================================================

Objective:
Standardize categorical text values to ensure consistent
grouping, filtering, and reporting across the analytical
dataset.

============================================================*/


/*------------------------------------------------------------
  Store
------------------------------------------------------------*/

UPDATE retail_sales_dedup
SET Store =
CASE
    WHEN TRIM(LOWER(Store)) = 'airport' THEN 'Airport'
    WHEN TRIM(LOWER(Store)) = 'city center' THEN 'City Center'
    WHEN TRIM(LOWER(Store)) = 'lakeside' THEN 'Lakeside'
    WHEN TRIM(LOWER(Store)) = 'north hub' THEN 'North Hub'
    WHEN TRIM(LOWER(Store)) = 'online' THEN 'Online'
    WHEN TRIM(LOWER(Store)) = 'west gate' THEN 'West Gate'
    ELSE Store
END;


/*------------------------------------------------------------
  Category
------------------------------------------------------------*/

UPDATE retail_sales_dedup
SET Category =
CASE
    WHEN TRIM(LOWER(Category)) = 'accessories' THEN 'Accessories'
    WHEN TRIM(LOWER(Category)) = 'electronics' THEN 'Electronics'
    WHEN TRIM(LOWER(Category)) = 'furniture' THEN 'Furniture'
    WHEN TRIM(LOWER(Category)) = 'gaming' THEN 'Gaming'
    WHEN TRIM(LOWER(Category)) = 'home appliances' THEN 'Home Appliances'
    WHEN TRIM(LOWER(Category)) = 'office supplies' THEN 'Office Supplies'
    ELSE Category
END;


/*============================================================
  06 | Reconstruct Missing Discount Values
==============================================================

Objective:
Reconstruct missing discount values using the financial
relationship between quantity, unit price, and recorded
revenue. This preserves the integrity of transactional
calculations while minimizing incomplete financial data.

============================================================*/


UPDATE retail_sales_dedup
SET `Discount %` = ROUND(
    (
        (
            (CAST(Quantity AS DECIMAL(10,2)) *
             CAST(`Unit Price` AS DECIMAL(10,2)))
            -
            CAST(Revenue AS DECIMAL(10,2))
        )
        /
        (
            CAST(Quantity AS DECIMAL(10,2)) *
            CAST(`Unit Price` AS DECIMAL(10,2))
        )
    ) * 100,
    2
)
WHERE `Discount %` IS NULL;


/*============================================================
  07 | Create Analysis-Ready Dataset
==============================================================

Objective:
Transform standardized business attributes into appropriate
analytical data types and create a structured dataset for
business analysis and Power BI reporting.

============================================================*/

CREATE TABLE retail_sales_clean AS

SELECT
    `Order ID`,

    CASE
        WHEN `Order Date` REGEXP '^[0-9]{4}-'
            THEN STR_TO_DATE(`Order Date`, '%Y-%m-%d')

        WHEN `Order Date` REGEXP '^[0-9]{2}/'
            THEN STR_TO_DATE(`Order Date`, '%d/%m/%Y')

        WHEN `Order Date` REGEXP '^[0-9]{2}-'
            THEN STR_TO_DATE(`Order Date`, '%m-%d-%Y')
    END AS order_date,

    Store,
    Region,
    `Customer Segment`,
    `Sales Channel`,
    Category,
    Subcategory,
    SKU,

    CAST(Quantity AS UNSIGNED) AS quantity,

    CAST(`Unit Price` AS DECIMAL(10,2)) AS unit_price,

    CAST(
        COALESCE(NULLIF(`Discount %`, ''), '0')
        AS DECIMAL(5,2)
    ) AS discount_percent,

    CAST(Revenue AS DECIMAL(12,2)) AS revenue,

    CAST(COGS AS DECIMAL(12,2)) AS cogs,

    CAST(`Shipping Cost` AS DECIMAL(10,2)) AS shipping_cost,

    CAST(Returned AS UNSIGNED) AS returned,

    CAST(
        NULLIF(`Customer Rating`, '')
        AS DECIMAL(3,1)
    ) AS customer_rating,

    `Payment Method`,
    `Shipping Mode`

FROM retail_sales_dedup;


/*============================================================
  08 | Create Final Analytical Dataset
==============================================================

Objective:
Create the final analytical dataset by consolidating all
completed transformations into a clean, consistent, and
reporting-ready data source for downstream analysis.

============================================================*/

CREATE TABLE retail_sales_clean_final AS

SELECT DISTINCT *
FROM retail_sales_clean;


/*------------------------------------------------------------
  Reporting Standardization
------------------------------------------------------------*/

UPDATE retail_sales_clean_final
SET Region = 'Unknown'
WHERE Region IS NULL;

/*============================================================
  09 | Post-Clean Validation
==============================================================

Objective:
Verify that the transformed dataset satisfies the expected
quality standards before business analysis and dashboard
development.

============================================================*/


/* Final Row Count */

SELECT COUNT(*) AS total_rows
FROM retail_sales_clean_final;


/* Duplicate Validation */

SELECT
    `Order ID`,
    COUNT(*) AS duplicate_count
FROM retail_sales_clean_final
GROUP BY `Order ID`
HAVING COUNT(*) > 1;


/* Missing Value Validation */

SELECT
    SUM(CASE WHEN Store IS NULL THEN 1 ELSE 0 END) AS missing_store,
    SUM(CASE WHEN Region IS NULL THEN 1 ELSE 0 END) AS missing_region,
    SUM(CASE WHEN `Customer Segment` IS NULL THEN 1 ELSE 0 END) AS missing_customer_segment,
    SUM(CASE WHEN `Discount %` IS NULL THEN 1 ELSE 0 END) AS missing_discount,
    SUM(CASE WHEN `Customer Rating` IS NULL THEN 1 ELSE 0 END) AS missing_customer_rating
FROM retail_sales_clean_final;




-- ============================================================*/
-- note ; 
/* 
A final DISTINCT is applied after text standardization and
data type conversion to remove any remaining duplicate records
that become identical following the transformation process.
*/



/*============================================================
  End of File

  This script documents the SQL transformations performed to
  convert the raw transactional dataset into a clean,
  standardized, and analysis-ready dataset for business
  intelligence and reporting.

============================================================*/

