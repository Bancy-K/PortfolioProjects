SELECT *
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 3,4


SELECT *
FROM [dbo].[CovidVaccinations]
ORDER BY 3,4

--select the datathat we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
ORDER BY 1,2

--looking at total cases vs total deaths
--shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM [dbo].[CovidDeaths]
WHERE location like '%kenya%'
AND continent IS NOT NULL
ORDER BY 1,2


--lookint at total cases vs population
--shows what percentage of population got covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS cases_percentage
FROM [dbo].[CovidDeaths]
WHERE location like '%kenya%'
AND continent IS NOT NULL
ORDER BY 1,2

--looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS percentagePopulationInfection
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percentagePopulationInfection DESC

--show countries with highest death rate compared to population
SELECT location, MAX(cast(total_deaths as int)) AS HighestDeathCount
--, MAX((total_deaths/population))*100 AS percentagePopulationDeaths
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathCount DESC

--break down by continent
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [dbo].[CovidDeaths]
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS death_percentage
FROM [dbo].[CovidDeaths]
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

SELECT *
FROM [dbo].[CovidDeaths] AS dea
JOIN [dbo].[CovidVaccinations] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--looking at total pop vs vaccination
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
FROM [dbo].[CovidDeaths] AS dea
JOIN [dbo].[CovidVaccinations] AS vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac




--TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentagePopulationVaccinated
FROM #PercentagePopulationVaccinated


--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM [dbo].[CovidDeaths] dea
JOIN [dbo].[CovidVaccinations] vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT * 
FROM PercentPopulationVaccinated