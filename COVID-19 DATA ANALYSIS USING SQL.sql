-- ============================================================
-- PROJECT: COVID-19 DATA ANALYSIS USING SQL
-- LEVEL: Beginner → Advanced (Step-by-Step Learning)
-- NOTE:
-- Data was pre-sorted in Excel (last 40 records used for clarity)
-- ============================================================

-- ============================================================
-- STEP 1: DATA EXPLORATION
-- Understanding structure of tables
-- ============================================================

SELECT TOP 100 * FROM CovidDeaths;
SELECT TOP 100 * FROM CovidVaccinations;

-- ============================================================
-- STEP 2: BASIC DATA CLEANING
-- Removing aggregated rows like 'World', 'Europe'
-- ============================================================

SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL;

-- ============================================================
-- STEP 3: HANDLING NULL VALUES (IMPORTANT)
-- NULLIF → prevents divide by zero
-- ISNULL / COALESCE → replace NULL with default values
-- ============================================================

SELECT 
    location,
    ISNULL(total_deaths, 0) AS TotalDeaths
FROM CovidDeaths;

SELECT 
    location,
    COALESCE(total_deaths, 0) AS TotalDeaths
FROM CovidDeaths;

-- ============================================================
-- STEP 4: BASIC CALCULATIONS
-- Death percentage = deaths / cases
-- ============================================================

SELECT 
    location, 
    date, 
    total_cases,
    total_deaths,
    (TRY_CAST(total_deaths AS FLOAT) / NULLIF(TRY_CAST(total_cases AS FLOAT),0)) * 100 AS DeathPercentage
FROM CovidDeaths
ORDER BY location, date;

-- ============================================================
-- STEP 5: INFECTION RATE (Cases vs Population)
-- ============================================================

SELECT 
    location, 
    date, 
    total_cases, 
    population,
    (TRY_CAST(total_cases AS FLOAT) / NULLIF(TRY_CAST(population AS FLOAT),0)) * 100 AS InfectionRate
FROM CovidDeaths
ORDER BY location, date;



-- ============================================================
-- STEP 6: AGGREGATION FUNCTIONS
-- MAX, SUM, AVG, MIN
-- ============================================================

SELECT 
    location,
    MAX(TRY_CAST(total_cases AS FLOAT)) AS MaxCases,
    MIN(TRY_CAST(total_cases AS FLOAT)) AS MinCases,
    AVG(TRY_CAST(new_cases AS FLOAT)) AS AvgCases,
    SUM(TRY_CAST(new_cases AS FLOAT)) AS TotalCases
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalCases DESC;

-- ============================================================
-- STEP 7: GROUP BY ANALYSIS
-- Highest infection rate per country
-- ============================================================

SELECT 
    location,
    population,
    MAX(total_cases) AS HighestCases,
    MAX(total_cases) * 100.0 / NULLIF(population,0) AS InfectionRate
FROM CovidDeaths
GROUP BY location, population
ORDER BY InfectionRate DESC;

-- ============================================================
-- STEP 8: DEATH ANALYSIS
-- ============================================================

-- Country-wise deaths
SELECT 
    location,
    MAX(TRY_CAST(total_deaths AS FLOAT)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeaths DESC;

-- Continent-wise deaths
SELECT 
    continent,
    MAX(TRY_CAST(total_deaths AS FLOAT)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeaths DESC;

-- ============================================================
-- STEP 9: GLOBAL ANALYSIS
-- ============================================================

-- Daily global numbers
SELECT 
    date,
    SUM(TRY_CAST(new_cases AS FLOAT)) AS TotalCases,
    SUM(TRY_CAST(new_deaths AS FLOAT)) AS TotalDeaths,
    SUM(TRY_CAST(new_deaths AS FLOAT)) * 100.0 / NULLIF(SUM(TRY_CAST(new_cases AS FLOAT)),0) AS DeathRate
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Overall global numbers
SELECT 
    SUM(TRY_CAST(new_cases AS FLOAT)) AS TotalCases,
    SUM(TRY_CAST(new_deaths AS FLOAT)) AS TotalDeaths
FROM CovidDeaths
WHERE continent IS NOT NULL;

-- ============================================================
-- STEP 10: JOIN (BASIC)
-- Combining deaths + vaccinations
-- ============================================================

SELECT *
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

-- ============================================================
-- STEP 11: INNER JOIN
-- Only matching records
-- ============================================================

SELECT 
    dea.location,
    dea.date,
    dea.total_cases,
    vac.new_vaccinations
FROM CovidDeaths dea
INNER JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

-- ============================================================
-- STEP 12: LEFT JOIN
-- Keeps all records from left table
-- ============================================================

SELECT 
    dea.location,
    dea.date,
    dea.total_cases,
    vac.new_vaccinations
FROM CovidDeaths dea
LEFT JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

-- ============================================================
-- STEP 13: HAVING CLAUSE
-- Filtering aggregated results
-- ============================================================

SELECT 
    location,
    SUM(new_cases) AS TotalCases
FROM CovidDeaths
GROUP BY location
HAVING SUM(new_cases) > 1000000;

-- ============================================================
-- STEP 14: CASE STATEMENT
-- Categorizing countries
-- ============================================================

SELECT 
    location,
    MAX(total_cases) AS TotalCases,
    CASE 
        WHEN MAX(total_cases) > 10000000 THEN 'High Impact'
        WHEN MAX(total_cases) > 1000000 THEN 'Medium Impact'
        ELSE 'Low Impact'
    END AS ImpactLevel
FROM CovidDeaths
GROUP BY location;

-- ============================================================
-- STEP 15: STRING FUNCTIONS
-- ============================================================

SELECT 
    UPPER(location),
    LOWER(location),
    LEN(location),
    LTRIM(RTRIM(location))
FROM CovidDeaths;

-- ============================================================
-- STEP 16: WINDOW FUNCTIONS (ADVANCED)
-- ============================================================

-- Row number
SELECT 
    location, 
    date,
    ROW_NUMBER() OVER (PARTITION BY location ORDER BY date) AS RowNum
FROM CovidDeaths;

-- Ranking
SELECT 
    location,
    RANK() OVER (ORDER BY MAX(total_cases) DESC) AS RankPosition
FROM CovidDeaths
GROUP BY location;

-- ============================================================
-- STEP 17: LAG FUNCTION (TIME ANALYSIS)
-- ============================================================

SELECT 
    continent,
    location, 
    date, 
    total_cases,

    LAG(TRY_CAST(total_cases AS FLOAT)) 
    OVER (PARTITION BY location ORDER BY date) AS PreviousDayCases,

    TRY_CAST(total_cases AS FLOAT) -
    LAG(TRY_CAST(total_cases AS FLOAT)) 
    OVER (PARTITION BY location ORDER BY date) AS DailyIncrease

FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY continent, location, date;

-- ============================================================
-- STEP 18: GROWTH PERCENTAGE
-- ============================================================

SELECT 
    location, 
    date, 
    total_cases,

    (TRY_CAST(total_cases AS FLOAT) -
     LAG(TRY_CAST(total_cases AS FLOAT)) 
     OVER (PARTITION BY location ORDER BY date))

    * 100.0 /

    NULLIF(
        LAG(TRY_CAST(total_cases AS FLOAT)) 
        OVER (PARTITION BY location ORDER BY date), 0
    ) AS GrowthPercentage

FROM CovidDeaths;

-- ============================================================
-- STEP 19: ROLLING VACCINATION COUNT
-- ============================================================

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,

    SUM(TRY_CAST(vac.new_vaccinations AS FLOAT)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) 
    AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

-- ============================================================
-- STEP 20: TEMP TABLE (INTERMEDIATE STORAGE)
-- ============================================================

DROP TABLE IF EXISTS #Percentpopulationvaccinated;

CREATE TABLE #Percentpopulationvaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population float,
    new_vaccinations float,
    RollingPeopleVaccinated float
);

INSERT INTO #Percentpopulationvaccinated
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,

    SUM(TRY_CAST(vac.new_vaccinations AS FLOAT)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date)

FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date;

SELECT * FROM #Percentpopulationvaccinated;

-- ============================================================
-- STEP 21: VIEW (FOR DASHBOARD / POWER BI)
-- ============================================================

CREATE VIEW Percentpopulationvaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,

    SUM(TRY_CAST(vac.new_vaccinations AS FLOAT)) 
    OVER (PARTITION BY dea.location ORDER BY dea.date) 
    AS RollingPeopleVaccinated

FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;