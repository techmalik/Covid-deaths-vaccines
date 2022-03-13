SELECT *
FROM PortfolioProject..coviddeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..covidvaccines
ORDER BY 3,4

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..coviddeaths
ORDER BY 1,2

-- Observe Total cases v Total deaths
-- Likelihood of dying if you have Covid

SELECT Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS PercentageDeath
FROM PortfolioProject..coviddeaths
WHERE Location = 'Nigeria'
ORDER BY date desc

-- Observing Total cases v Population
SELECT Location, date, total_cases, population, total_deaths, (Total_cases/population)*100 AS PercentagePopulationwithCovid
FROM PortfolioProject..coviddeaths
WHERE Location = 'Nigeria'
ORDER BY date desc


-- Observing Total deaths v Population
SELECT Location, date, total_cases, population, total_deaths, (Total_cases/population)*100 AS PercentagePopulationwithCovid
FROM PortfolioProject..coviddeaths

WHERE Location = 'Nigeria'
ORDER BY date desc


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

-- By continent
SELECT continent, MAX(CAST(total_deaths AS int)) as TotalDeathCount,  MAX((total_deaths/population))*100 AS PercentagePopulationDeath
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

-- Global
SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject..coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY date desc

-- Joining Coviddeaths table with Covidvaccine table
SELECT cd.continent, cd.location, cd.date, cd. population, cv.new_vaccinations, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.location Order by cd.location, cd.date) AS RollingPeopleVaccinated
FROM PortfolioProject..coviddeaths as cd
JOIN PortfolioProject..covidvaccines as cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent is not null
ORDER BY date, continent desc

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
