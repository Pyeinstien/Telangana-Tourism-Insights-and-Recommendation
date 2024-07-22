-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x
-- PRELIMINARY RESEARCH INSIGHTS
-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- Viewing the original tables:
SELECT * FROM DOMESTIC_VISITORS;
SELECT * FROM FORIEGNERS_VISITORS;

-- 1. Top 10 districts with highest number of domestic visitors overall (2016 - 2019)

SELECT DISTRICT, SUM(VISITORS) AS TOTAL_VISITORS
FROM DOMESTIC_VISITORS
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- 2. Top 3 disctricts based on compounded annual growth rate of domestic visitors
   -- CAGR% = (End Value / start value)**(1/n) * 100  (n = no of years span)

WITH visitor_totals AS (
    SELECT 
        district,
        SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016,
        SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019
    FROM DOMESTIC_VISITORS
    WHERE year IN (2016, 2019)
    GROUP BY district
),
cagr_calculation AS (
    SELECT
        district,
        CASE
            WHEN visitors_2016 > 0 AND visitors_2016 > 0
            THEN (POW((visitors_2019::FLOAT / visitors_2016), 1.0 / 3) - 1) * 100
            ELSE NULL
        END AS cagr
    FROM visitor_totals
)
SELECT district, cagr
FROM cagr_calculation
WHERE cagr IS NOT NULL
ORDER BY cagr DESC
LIMIT 3;

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- 3. BOTTOM 3 disctricts based on compounded annual growth rate of domestic visitors

WITH visitor_totals AS (
    SELECT 
        district,
        SUM(CASE WHEN year = 2016 THEN visitors ELSE 0 END) AS visitors_2016,
        SUM(CASE WHEN year = 2019 THEN visitors ELSE 0 END) AS visitors_2019
    FROM DOMESTIC_VISITORS
    WHERE year IN (2016, 2019)
    GROUP BY district
),
cagr_calculation AS (
    SELECT
        district,
        CASE
            WHEN visitors_2016 > 0 AND visitors_2016 > 0
            THEN (POW((visitors_2019::FLOAT / visitors_2016), 1.0 / 3) - 1) * 100
            ELSE NULL
        END AS cagr
    FROM visitor_totals
)
SELECT district, cagr
FROM cagr_calculation
WHERE cagr IS NOT NULL
ORDER BY cagr
LIMIT 3;

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- 4. What are peak and low season months of hyderabad based on domestic visitors from 2016-2019.

SELECT month, SUM(visitors) as TOTAL_VISITORS
FROM DOMESTIC_VISITORS
WHERE district = 'Hyderabad'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

SELECT month, SUM(visitors) as TOTAL_VISITORS
FROM DOMESTIC_VISITORS
WHERE district = 'Hyderabad'
GROUP BY 1
ORDER BY 2
LIMIT 3;

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x

-- 5. Top and bottom 3 districts with high domestic to foriegn tourist ratio

WITH DOMESTIC_TOTALS AS (
	SELECT district,
	SUM(visitors) as total_domestic
	FROM DOMESTIC_VISITORS
	GROUP BY 1
),
FORIEGNER_TOTALS AS (
	SELECT district,
	SUM(visitors) as total_foriegners
	FROM FORIEGNERS_VISITORS
	GROUP BY 1
),
COMBINED AS (
	SELECT D.district,
	D.total_domestic, 
	F.total_foriegners
	FROM DOMESTIC_TOTALS D
	JOIN FORIEGNER_TOTALS F
	ON D.district = F.district
),
VISITORS_RATIO AS (
	SELECT district,
	CASE
		WHEN total_foriegners > 0
		THEN ROUND((total_foriegners::FLOAT/ total_domestic)::DECIMAL, 5)
		ELSE NULL
	END AS RATIO
	FROM COMBINED
)
SELECT district, RATIO
FROM VISITORS_RATIO
WHERE VISITORS_RATIO IS NOT NULL
ORDER BY 2 DESC
LIMIT 3;

-- INSIGHT: Hyderabad, Warangal(Rural) and Mulugu have the most foreigner tourist attraction.

WITH DOMESTIC_TOTALS AS (
	SELECT district,
	SUM(visitors) as total_domestic
	FROM DOMESTIC_VISITORS
	GROUP BY 1
),
FORIEGNER_TOTALS AS (
	SELECT district,
	SUM(visitors) as total_foriegners
	FROM FORIEGNERS_VISITORS
	GROUP BY 1
),
COMBINED AS (
	SELECT D.district,
	D.total_domestic, 
	F.total_foriegners
	FROM DOMESTIC_TOTALS D
	JOIN FORIEGNER_TOTALS F
	ON D.district = F.district
),
VISITORS_RATIO AS (
	SELECT district,
	CASE
		WHEN total_foriegners > 0
		THEN ROUND((total_foriegners::FLOAT/ total_domestic)::DECIMAL, 8)
		ELSE NULL
	END AS RATIO
	FROM COMBINED
)
SELECT district, RATIO
FROM VISITORS_RATIO
WHERE VISITORS_RATIO IS NOT NULL
ORDER BY 2 
LIMIT 3;

-- INSIGHT: More than 20 districts have 0 foreigner tourists,
-- 		    Nirmal, Jangaon, Adilabad concedes lowest foreigner tourist attraction

-- x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x-x