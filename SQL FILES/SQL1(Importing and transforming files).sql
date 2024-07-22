-- IMPORTING DATASETS AND TRANSFORMING DATA TYPES

CREATE TABLE DOMESTIC (
	"district" TEXT,
	"date"	TEXT,
	"month"	TEXT,
	"year"	INT,
	"visitors" TEXT
);

COPY DOMESTIC
FROM 'D:\C5 Input for participants\domestic_visitors\domestic_visitors_2016.csv'
DELIMITER ','
CSV HEADER;
COPY DOMESTIC
FROM 'D:\C5 Input for participants\domestic_visitors\domestic_visitors_2017.csv'
DELIMITER ','
CSV HEADER;
COPY DOMESTIC
FROM 'D:\C5 Input for participants\domestic_visitors\domestic_visitors_2018.csv'
DELIMITER ','
CSV HEADER;
COPY DOMESTIC
FROM 'D:\C5 Input for participants\domestic_visitors\domestic_visitors_2019.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE DOMESTIC_VISITORS (
    "district" TEXT,
    "date" DATE,
    "month" TEXT,
    "year" INTEGER,
    "visitors" INTEGER DEFAULT 0
);

INSERT INTO DOMESTIC_VISITORS ("district", "date", "month", "year", "visitors")
SELECT
    "district",
    TO_DATE("date", 'DD-MM-YYYY'),
    "month",
    "year",
    CASE 
        WHEN TRIM("visitors") = '' THEN 0 
        ELSE "visitors"::INTEGER 
    END
FROM DOMESTIC;

CREATE TABLE FORIEGNERS (
	"district" TEXT,
	"date"	TEXT,
	"month"	TEXT,
	"year"	INT,
	"visitors" TEXT
);

COPY FORIEGNERS
FROM 'D:\C5 Input for participants\foreign_visitors\foreign_visitors_2016.csv'
DELIMITER ','
CSV HEADER;
COPY FORIEGNERS
FROM 'D:\C5 Input for participants\foreign_visitors\foreign_visitors_2017.csv'
DELIMITER ','
CSV HEADER;
COPY FORIEGNERS
FROM 'D:\C5 Input for participants\foreign_visitors\foreign_visitors_2018.csv'
DELIMITER ','
CSV HEADER;
COPY FORIEGNERS
FROM 'D:\C5 Input for participants\foreign_visitors\foreign_visitors_2019.csv'
DELIMITER ','
CSV HEADER;

SELECT * FROM FORIEGNERS;

CREATE TABLE FORIEGNERS_VISITORS (
    "district" TEXT,
    "date" DATE,
    "month" TEXT,
    "year" INTEGER,
    "visitors" INTEGER DEFAULT 0
);

INSERT INTO FORIEGNERS_VISITORS ("district", "date", "month", "year", "visitors")
SELECT
    "district",
    TO_DATE("date", 'DD-MM-YYYY'),
    "month",
    "year",
    CASE 
        WHEN TRIM("visitors") = '' THEN 0 
        ELSE "visitors"::INTEGER 
    END
FROM FORIEGNERS;

SELECT * FROM DOMESTIC_VISITORS;
SELECT * FROM FORIEGNERS_VISITORS;

DROP TABLE DOMESTIC;
DROP TABLE FORIEGNERS;

CREATE TABLE POPULATION(
	district TEXT,
	"population(2011)" TEXT,
	population TEXT
)
DROP TABLE POPULATION;
COPY POPULATION
FROM 'D:\C5 Input for participants\Combined Files\district_pop.csv'
DELIMITER ','
CSV HEADER;
SELECT * FROM POPULATION;

CREATE TABLE DISTRICT_POP(
	district TEXT,
	"population(2011)" INT,
	population INT
)

INSERT INTO DISTRICT_POP (district, "population(2011)", population)
SELECT
	district,
    CASE 
        WHEN TRIM("population(2011)") = '' THEN 0 
        ELSE REPLACE("population(2011)", ',', '')::INTEGER 
    END,
    CASE 
        WHEN TRIM(population) = '' THEN 0 
        ELSE REPLACE(population, ',', '')::INTEGER 
    END
FROM POPULATION;
SELECT * FROM DISTRICT_POP;

CREATE TABLE REVENUE(
	Tourist text,
	Revenue text
)
COPY REVENUE
FROM 'D:\C5 Input for participants\Combined Files\Tourist_Rev.csv'
DELIMITER ','
CSV HEADER;

CREATE TABLE TOURIST_REV(
	Tourist text,
	Revenue int
)
INSERT INTO TOURIST_REV (Tourist, Revenue)
SELECT
	Tourist,
    CASE 
        WHEN TRIM(Revenue) = '' THEN 0 
        ELSE REPLACE(Revenue, ',', '')::FLOAT 
    END
FROM REVENUE;
SELECT * FROM TOURIST_REV;
DROP TABLE REVENUE;