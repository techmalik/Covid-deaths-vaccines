-- *****EXPLORING COVID DEATHS AND COVID VACCINATIONS***** --

-- Exploring the dataset 
SELECT *
FROM PortfolioProject..coviddeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..covidvaccines
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER BY 1,2

-- EXPLORING NIGERIA
-- Observe Total cases v Total deaths i.e. likelihood of dying if you have Covid in Nigeria

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS PercentageDeath
FROM PortfolioProject..coviddeaths
WHERE Location = 'Nigeria'
ORDER BY date desc

-- Observing Total cases v Population in Nigeria
SELECT Location, date, total_cases, population, total_deaths, (Total_cases/population)*100 AS PercentagePopulationwithCovid
FROM PortfolioProject..coviddeaths
WHERE Location = 'Nigeria'
ORDER BY date desc

-- GLOBAL 
-- Countries with highest infection rate compared with population
SELECT Location, MAX(total_cases) as HighestInfectionCount, population, MAX((Total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected desc

-- Countries with highest deaths by population
SELECT Location, MAX(CAST(total_deaths AS int)) as HighestDeathCount,  MAX((total_deaths/population))*100 AS PercentagePopulationDeath
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY Location
ORDER BY HighestDeathCount desc

-- Continents with highest deaths by population
SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount,  MAX((total_deaths/population))*100 AS PercentagePopulationDeath
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global trend of cases and deaths
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY date desc

-- JOINING TWO TABLES
-- Joining Coviddeaths table with Covidvaccine table using CTE
With Population_Vaccinated (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM Population_Vaccinated

-- Create View for visualization
CREATE View RollingPeopleVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null

-- Views (Global numbers)
CREATE View Global_numbers AS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE continent is not null

-- Views (Total deaths by Continent)
CREATE View death_continent AS
SELECT location, SUM(CAST(new_deaths as int)) as TotalDeathCount
FROM PortfolioProject..coviddeaths
WHERE continent is null
and location not in ('Low income','Lower middle income', 'High income', 'Upper middle income', 'World', 'European Union', 'International')
GROUP BY location
ORDER BY TotalDeathCount desc

-- Views (Population, Total Infection & Percentage Population Infected)
CREATE View Population_PercInfected AS
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((Total_cases/population))*100 AS PercentagePopulationInfected
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected desc


-- Views (cardiovasc_death_rate v covid death rate total_deaths/total_cases)
CREATE View cardio_covid_deathrate AS
SELECT cd.location, AVG(cv.cardiovasc_death_rate) as cardiovasc_death_rate, MAX(cd.total_deaths/cd.total_cases) as covid_death_rate
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.location
ORDER BY covid_death_rate desc

-- View (trend of new_vaccinations v new_cases)
CREATE View trend_cases_vaccines AS
SELECT cd.date, SUM(CONVERT(float,cv.new_vaccinations)) as vaccinations, SUM(CONVERT(float,cd.new_cases)) as cases
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.date
ORDER BY cd.date desc

-- View (population_density v total_cases)
CREATE View Populationdensity_cases AS
SELECT cd.location, AVG(cv.population_density) AS population_density, MAX(cd.total_cases) as total_cases
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.location
ORDER BY population_density desc

-- View (gdp_per_capita v total_cases)
CREATE View gdp_cases AS
SELECT cd.location, AVG(cv.gdp_per_capita) as gdp_per_capita, MAX(cd.total_cases) as total_cases
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.location
ORDER BY total_cases desc

-- View (aged_65_older v total_deaths)
CREATE View age65deaths AS
SELECT cd.location, Avg(cv.aged_65_older) as perc_aged_65_older, MAX(cd.total_deaths) as total_deaths
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
GROUP BY cd.location
ORDER BY total_deaths desc
