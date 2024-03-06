--Select Data that we are going to use
SELECT location, date, total_cases, new_cases, total_deaths,population
FROM PortfolioProject.dbo.CovidDeaths$
ORDER BY 1,2

--Looking at the total cases VS total deaths

-- Total deaths, total cases, death percentage by day in Cameroon
SELECT Location, date,
(CASE
	WHEN total_cases IS NULL THEN 0
	ELSE total_cases
	END) AS Total_cases,
(CASE
	WHEN total_deaths IS NULL THEN 0
	ELSE total_deaths
	END) AS Total_deaths,
(CASE
	WHEN total_cases IS NULL THEN 0
	WHEN total_deaths IS NULL THEN 0
	ELSE (total_deaths / total_cases)*100
	END) AS Death_percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Location LIKE '%Cameroon%'

-- Total death percentage in Cameroon (handling null values)
SELECT Location,
       MIN(date) AS Start_Date,
       MAX(date) AS End_Date,
       MAX(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS bigint) ELSE NULL END) AS Total_Cases,
       MAX(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS bigint) ELSE NULL END) AS Total_Deaths,
       CASE -- Handle null values in the division
           WHEN MAX(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS bigint) ELSE NULL END) IS NOT NULL
              AND MAX(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS bigint) ELSE NULL END) IS NOT NULL
           THEN (MAX(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS bigint) ELSE NULL END) * 100.0)
              / (MAX(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS bigint) ELSE NULL END))
           ELSE NULL
       END AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE ISNUMERIC(total_cases) = 1 -- Assuming non-numeric values are filtered in source data
GROUP BY Location
HAVING Location LIKE '%Cameroon%';




--percentage of cases and death by population in every country
SELECT Location, population,
MAX(CAST(total_cases AS bigint)) AS Total_Cases,
MAX(CAST(total_deaths AS bigint)) AS Total_Deaths,
( MAX(CAST(total_cases AS bigint)) /population )*100 AS Cases_Percentage_By_Population,
( MAX(CAST(total_deaths AS bigint)) /population )*100 AS Deaths_Percentage_By_Population
FROM PortfolioProject.dbo.CovidDeaths$
GROUP BY Location, population
ORDER BY Location
--for only Cameroon, Uncomment row below
--HAVING Location LIKE '%Cameroon'	
 

--Country with the highest infection rate compared to population
SELECT Location, population,
MAX(CAST(total_cases AS bigint)) AS Total_Cases,
MAX(CAST(total_deaths AS bigint)) AS Total_Deaths,
( MAX(CAST(total_cases AS bigint)) / population )*100 AS Cases_Percentage_By_Population,
( MAX(CAST(total_deaths AS bigint)) / population )*100 AS Deaths_Percentage_By_Population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY Cases_Percentage_By_Population DESC

--country with the highest death percentage rate by population
SELECT Location, population,
MAX(CAST(total_cases AS bigint)) AS Total_Cases,
MAX(CAST(total_deaths AS bigint)) AS Total_Deaths,
( MAX(CAST(total_cases AS bigint)) / population )*100 AS Cases_Percentage_By_Population,
( MAX(CAST(total_deaths AS bigint)) / population )*100 AS Deaths_Percentage_By_Population
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location, population
ORDER BY Deaths_Percentage_By_Population DESC

--Country with the most deaths
SELECT Location, MAX(CAST(total_deaths AS Bigint)) AS Total_Deaths
FROM PortfolioProject.dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Deaths DESC

-- Total Deaths by continent
SELECT Location, MAX(CAST(total_deaths AS Bigint)) AS Total_Deaths
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent IS NULL
GROUP BY Location
ORDER BY Total_Deaths DESC

-- Continent with the highest deaths per population
SELECT Location, 
population,
MAX(CAST(total_deaths AS Bigint)) AS Total_Deaths,
MAX(CAST(total_deaths AS bigint)) /population *100 AS Death_Percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE Continent IS NULL
AND Location NOT IN ( 'World', 'International')
GROUP BY continent, population, Location
ORDER BY Death_Percentage DESC

--GLOBAL NUMBERS 

--cases and deaths per day across the world
SELECT Location,date,
MAX(CAST(total_cases AS bigint)) AS Total_Cases , 
MAX(CAST(total_deaths AS BigInt))  AS Total_Deaths,
 CASE -- Handle null values in the division
           WHEN MAX(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS bigint) ELSE NULL END) IS NOT NULL
              AND MAX(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS bigint) ELSE NULL END) IS NOT NULL
           THEN (MAX(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS bigint) ELSE NULL END) * 100.0)
              / (MAX(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS bigint) ELSE NULL END))
           ELSE NULL
       END AS Death_Cases_Percentage,
	   MAX(CAST(total_deaths AS BigInt))*100 / population  AS Deaths_Population_Percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location = 'World' AND ISNUMERIC(total_cases) = 1
GROUP BY Location, date, population

--cases and deaths across the world
SELECT Location,population,
MAX(CAST(total_cases AS bigint)) AS Total_Cases , 
MAX(CAST(total_deaths AS BigInt))  AS Total_Deaths,
 CASE -- Handle null values in the division
           WHEN MAX(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS bigint) ELSE NULL END) IS NOT NULL
              AND MAX(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS bigint) ELSE NULL END) IS NOT NULL
           THEN (MAX(CASE WHEN ISNUMERIC(total_deaths) = 1 THEN CAST(total_deaths AS bigint) ELSE NULL END) * 100.0)
              / (MAX(CASE WHEN ISNUMERIC(total_cases) = 1 THEN CAST(total_cases AS bigint) ELSE NULL END))
           ELSE NULL
       END AS Death_Cases_Percentage,
	   MAX(CAST(total_deaths AS BigInt))*100 / population  AS Deaths_Population_Percentage
FROM PortfolioProject.dbo.CovidDeaths$
WHERE location = 'World' AND ISNUMERIC(total_cases) = 1
GROUP BY Location, population;

--Let'us start using Vaccination Table

-- Total vaccinations compared to the population
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Total_People_Vaccinated)
AS(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Continent, dea.DATE) AS Total_People_Vaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
)
--SELECT * FROM PopvsVac
--WHERE Location LIKE '%Afghanistan%'
SELECT Location, Population,
MAX(CAST(Total_People_Vaccinated AS bigint))*100 / Population AS Percentage_People_vaccinated
FROM PopvsVac
GROUP BY Location, Population
ORDER BY 1;

-- Creating View to store data for visualizations 
DROP VIEW  IF EXISTS PercentPopulationVaccinated;

CREATE VIEW  PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.Continent, dea.DATE) AS Total_People_Vaccinated
FROM PortfolioProject.dbo.CovidDeaths$ dea
JOIN PortfolioProject.dbo.CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
