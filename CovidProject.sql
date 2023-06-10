-- Select the data i'm going to be using

SELECT 
  location, date, total_cases, new_cases, total_deaths, population

FROM 
  `Project1.covid_deaths`

WHERE
continent is not null 

ORDER BY 
  1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

SELECT 
  location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage

FROM 
  `Project1.covid_deaths`
  WHERE location='Greece'

ORDER BY 
  1,2

-- Looking at the total cases vs the population
-- Shows what percentage of the population got covid

SELECT 
  location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected

FROM 
  `Project1.covid_deaths`
  WHERE location='Greece'

ORDER BY 
  1,2

-- Looking at countries with Highest Infection Rate compared to Population

SELECT 
  location, MAX(total_cases) as HighestInfectionCount, population, MAX((total_cases/population))*100 as PercentPopulationInfected

FROM 
  `Project1.covid_deaths`
-- WHERE location='Greece'

GROUP BY location, population

ORDER BY 
  PercentPopulationInfected DESC

-- Showing Countries with the Highest Death Count per Popoulation 

SELECT 
  location,MAX(cast(Total_deaths as int)) as TotalDeathCount

FROM 
  `Project1.covid_deaths`

WHERE
  continent is not null 

GROUP BY location

ORDER BY 
  TotalDeathCount DESC

-- Let's break things down by continent
-- Showing the continents with the highest death count

SELECT 
  continent,MAX(cast(Total_deaths as int)) as TotalDeathCount

FROM 
  `Project1.covid_deaths`

WHERE
  continent is not null 

GROUP BY continent

ORDER BY 
  TotalDeathCount DESC

-- Global Numbers 

SELECT 
  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage

FROM 
  `Project1.covid_deaths`

WHERE 
continent is not null
and new_cases!=0

ORDER BY
  1,2

-- Looking at total population vs vaccinations

-- USE CTE

WITH PopvsVac AS (
  SELECT 
    dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
    SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM 
    `Project1.covid_deaths` AS dea
  JOIN 
    `Project1.covid_vaccinations` AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated / population) * 100
FROM PopvsVac;



-- Temp Table

DROP TABLE IF EXISTS Project1.percentpopulationvaccinated;
CREATE TABLE Project1.percentpopulationvaccinated (
  Continent string(255),
  Location string(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
);

INSERT INTO percentpopulationvaccinated
SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
  `Project1.covid_deaths` AS dea
JOIN 
  `Project1.covid_vaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL;

SELECT *, (RollingPeopleVaccinated / population) * 100
FROM Project1.percentpopulationvaccinated;

-- Creating View to store data for later visualizations

DROP TABLE IF EXISTS Project1.percentpopulationvaccinated;

Create View Project1.percentpopulationvaccinated AS

SELECT 
  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
  SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
  `Project1.covid_deaths` AS dea
JOIN 
  `Project1.covid_vaccinations` AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE 
  dea.continent IS NOT NULL;

SELECT *

FROM 
  Project1.percentpopulationvaccinated