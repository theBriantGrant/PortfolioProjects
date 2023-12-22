SELECT *
FROM PortfolioProject..CovidVaccination$
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..covidDeaths$
WHERE continent IS NOT NULL
ORDER BY 1,2

--Total cases vs total deaths
--Shows likelyhood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercent
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

ALTER TABLE	PortfolioProject..covidDeaths$
ALTER COLUMN total_death float

--Total cases vs population
SELECT location, date, total_cases,population,(total_cases/population)*100 as InfectedPopulationPercent
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
ORDER BY 1,2

--Countries with highest infection rate per population
SELECT location, MAX(total_cases) as HighestInfectionCount ,population,MAX((total_cases/population))*100 as InfectedPopulationPercent
FROM PortfolioProject..covidDeaths$
WHERE location like '%states%' AND continent IS NOT NULL
GROUP BY population, location
ORDER BY 4 DESC

--Highest death count per population
SELECT location, MAX(total_deaths)*100 as TotalDeathCount
FROM PortfolioProject..covidDeaths$
GROUP BY location
ORDER BY 2 DESC

--Highest death count by continent
SELECT location, MAX(total_deaths)*100 as TotalDeathCount
FROM PortfolioProject..covidDeaths$
WHERE continent IS  NULL
GROUP BY location
ORDER BY 2 DESC

--Using PARTITION to look at total pop vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Using CTE and CONVERT
WITH PopvsVac (Continenet, location, date, population, New_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(BIGINT,vac.new_vaccinations AS)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--Using temp table 
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
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

--Creating view to store data for vizualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location,
dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccination$ vac
	ON dea.location=vac.location
	and dea.date=vac.date
WHERE dea.continent IS NOT NULL
