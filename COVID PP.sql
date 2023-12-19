SELECT *
FROM PortfolioProject..CovidVaccination$
WHERE continent IS NOT NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidDeaths$
--ORDER BY 3,4

--Select data that we are going to beusing

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--loking at total cases vs total deaths
--shows likelyhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercent
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

ALTER TABLE	PortfolioProject..covidDeaths$
ALTER COLUMN total_death float

--looking at total cases vs population
--shows what percentage of populatino has gotten covid
SELECT location, date, total_cases,population,(total_cases/population)*100 as InfectedPopulationPercent
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--countries with highest infection rate compared to populations
SELECT location, MAX(total_cases) as HighestInfectionCount ,population,MAX((total_cases/population))*100 as InfectedPopulationPercent
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
GROUP BY population, location
ORDER BY 4 DESC


--counties with highest death count per population
SELECT location, MAX(total_deaths)*100 as TotalDeathCount
FROM PortfolioProject..covidDeaths$
--WHERE location like '%states%' AND continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC

--LETS BREAK THINGS DOWN BY CONTINENT
--continents with highest death cap
SELECT location, MAX(total_deaths)*100 as TotalDeathCount
FROM PortfolioProject..covidDeaths$
WHERE continent IS  NULL
GROUP BY location
ORDER BY 2 DESC

--GLOBAL NUMBERS GET DIV BY 0 ERROR
SELECT date, SUM(new_cases) as Total_Cases, SUM(new_deaths) as Total_Deaths, SUM(new_deaths)/SUM(New_cases)*100 --total_deaths, (total_deaths/total_cases)*100 DeathPercent
FROM PortfolioProject..covidDeaths$
--WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 DESC

--looking at total pop vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location,
--SUM(CONVERT(BIGINT,vac.new_vaccinations AS int))
dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--use CTE
WITH PopvsVac (Continenet, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location,
--SUM(CONVERT(BIGINT,vac.new_vaccinations AS int))
dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Use temp table
DROP Table IF exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location,
--SUM(CONVERT(BIGINT,vac.new_vaccinations AS int))
dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--creating view to store data for vizualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location,
--SUM(CONVERT(BIGINT,vac.new_vaccinations AS int))
dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3