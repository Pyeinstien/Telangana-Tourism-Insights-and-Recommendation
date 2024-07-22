-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
-- SECONDARY RESEARCH INSIGHTS
-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- Some Data Cleaning

UPDATE FORIEGNERS_VISITORS SET district = 'Narayanapet' where district = 'Narayanpet';

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- 1. Top and bottom 5 districts based on population to tourist footfall ratio in 2019
-- 	ratio = total visitors / total population in that year

WITH TOTAL_TOURISTS AS (
	SELECT
	d.district, 
	coalesce(sum(d.visitors),0) as dom_visitors,
	coalesce(sum(f.visitors),0) as for_visitors,
	COALESCE(SUM(d.visitors), 0) + COALESCE(SUM(f.visitors), 0) as total_visitors
	FROM DOMESTIC_VISITORS d JOIN FORIEGNERS_VISITORS f ON d.district = f.district
	AND d.year = f.year
	WHERE d.year = 2019
	GROUP BY 1
),
TOURIST_POP_RATIO AS (
	SELECT
	t.district,
	t.total_visitors,
	p.population,
	ROUND((t.total_visitors::float / p.population)::DECIMAL, 3) as TP_RATIO
	FROM TOTAL_TOURISTS t JOIN DISTRICT_POP p ON t.district = p.district
)
SELECT
	district,
	total_visitors,
	population,
	TP_RATIO
	FROM TOURIST_POP_RATIO
	ORDER BY 4 DESC
	LIMIT 5;

WITH TOTAL_TOURISTS AS (
	SELECT
	d.district, 
	coalesce(sum(d.visitors),0) as dom_visitors,
	coalesce(sum(f.visitors),0) as for_visitors,
	COALESCE(SUM(d.visitors), 0) + COALESCE(SUM(f.visitors), 0) as total_visitors
	FROM DOMESTIC_VISITORS d JOIN FORIEGNERS_VISITORS f ON d.district = f.district
	AND d.year = f.year
	WHERE d.year = 2019
	GROUP BY 1
),
TOURIST_POP_RATIO AS (
	SELECT
	t.district,
	t.total_visitors,
	p.population,
	ROUND((t.total_visitors::float / p.population)::DECIMAL, 3) as TP_RATIO
	FROM TOTAL_TOURISTS t JOIN DISTRICT_POP p ON t.district = p.district
)
SELECT
	district,
	total_visitors,
	population,
	TP_RATIO
	FROM TOURIST_POP_RATIO
	WHERE TP_RATIO != 0
	ORDER BY 4
	LIMIT 5;

-- INSIGHT: 4 districts have 0 visitors in 2019
-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- 2. Projected Number of domestic and foreign tourist in year 2025 in Hyderabad district
	 -- CAGR = CAGR% = (End Value / start value)**(1/n)  (n = no of years span)
	 -- projection = original((1 + CAGR)**n)

WITH dom_visitors_totals AS (
    SELECT 
        district,
        sum(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016,
        SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019
    FROM DOMESTIC_VISITORS
    WHERE year IN (2016, 2019)
    GROUP BY 1
),
for_visitors_totals AS (
    SELECT 
        district,
        sum(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016,
        SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019
    FROM FORIEGNERS_VISITORS
    WHERE year IN (2016, 2019)
    GROUP BY 1
),
cagr_calculation AS (
    SELECT
        d.district,
		d.visitors_2019 as dom_vis,
		f.visitors_2019 as for_vis,
        CASE
            WHEN d.visitors_2016 IS NOT NULL AND d.visitors_2019 > 0
            THEN ROUND((POW((d.visitors_2019::FLOAT / d.visitors_2016), 1.0 / 3) - 1)::DECIMAL, 3)
            ELSE NULL
        END AS D_cagr,
		CASE
            WHEN f.visitors_2016 IS NOT NULL AND f.visitors_2019 > 0
            THEN ROUND((POW((f.visitors_2019::FLOAT / f.visitors_2016), 1.0 / 3) - 1)::DECIMAL,3)
            ELSE NULL
        END AS F_cagr
    FROM dom_visitors_totals d join for_visitors_totals f on d.district = f.district
)
SELECT
	district,
	dom_vis,
	D_cagr,
	F_cagr,
	ROUND((dom_vis*POWER(1+D_cagr,6))::decimal,0) AS PROJECTED_DOMESTIC_VISITORS,
	for_vis,
	ROUND(for_vis*POWER(1+f_cagr,6)::decimal,0) AS PROJECTED_FORIEGNER_VISITORS
	FROM cagr_calculation
WHERE district = 'Hyderabad'

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- 3. Estimate projected revenue for hyderabad in 2025 based on average spen per tourist 
WITH dom_visitors_totals AS (
    SELECT 
        district,
        sum(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016,
        SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019
    FROM DOMESTIC_VISITORS
    WHERE year IN (2016, 2019)
    GROUP BY 1
),
for_visitors_totals AS (
    SELECT 
        district,
        sum(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016,
        SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019
    FROM FORIEGNERS_VISITORS
    WHERE year IN (2016, 2019)
    GROUP BY 1
),
cagr_calculation AS (
    SELECT
        d.district,
		d.visitors_2019 as dom_vis,
		f.visitors_2019 as for_vis,
        CASE
            WHEN d.visitors_2016 IS NOT NULL AND d.visitors_2019 > 0
            THEN ROUND((POW((d.visitors_2019::FLOAT / d.visitors_2016), 1.0 / 3) - 1)::DECIMAL, 3)
            ELSE NULL
        END AS D_cagr,
		CASE
            WHEN f.visitors_2016 IS NOT NULL AND f.visitors_2019 > 0
            THEN ROUND((POW((f.visitors_2019::FLOAT / f.visitors_2016), 1.0 / 3) - 1)::DECIMAL,3)
            ELSE NULL
        END AS F_cagr
    FROM dom_visitors_totals d join for_visitors_totals f on d.district = f.district
),
PROJECTED_VISITORS AS(
SELECT
	district,
	ROUND((dom_vis*POWER(1+D_cagr,6))::decimal,0) AS PROJECTED_DOMESTIC_VISITORS,
	ROUND(for_vis*POWER(1+f_cagr,6)::decimal,0) AS PROJECTED_FORIEGNER_VISITORS
	FROM cagr_calculation
	WHERE district = 'Hyderabad'
),
PROJECTED_REVENUE AS (
	SELECT
	district,
	PROJECTED_DOMESTIC_VISITORS,
	PROJECTED_FORIEGNER_VISITORS,
	r_domestic.revenue AS revenue_domestic,
	r_foreign.revenue AS revenue_foreign
    FROM
        PROJECTED_VISITORS p
    CROSS JOIN
        (SELECT revenue FROM tourist_rev WHERE tourist = 'Domestic') r_domestic,
        (SELECT revenue FROM tourist_rev WHERE tourist = 'Foreign') r_foreign
)
SELECT
	district,
	PROJECTED_DOMESTIC_VISITORS*revenue_domestic AS  PROJECTED_revenue_domestic,
	PROJECTED_FORIEGNER_VISITORS*revenue_foreign AS PROJECTED_revenue_foreign
	from PROJECTED_REVENUE;

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x