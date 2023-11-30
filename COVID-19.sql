SELECT * 
FROM PortfolioProfile..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProfile..CovidVaccination
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date , total_cases, new_cases, total_deaths, population
FROM PortfolioProfile..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Malaysia
SELECT location, date , total_cases, new_cases, total_deaths, (total_deaths * 1.0)/(total_cases)*100 as DeathPercentage
FROM PortfolioProfile..CovidDeaths
WHERE location like '%Malay%'
and continent is not null
ORDER BY 1,2

-- Looking at Total cases vs Population
SELECT location, date , population, total_cases, (total_cases * 1.0)/(population)*100 as PercentPopluationInfected
FROM PortfolioProfile..CovidDeaths
WHERE location like '%Hong%'
and continent is not null
ORDER BY 1,2

-- Looking at Countries with Highest Infection rate compared to Population
SELECT location,  population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases * 1.0)/(population))*100 as PercentPopulationInfected
FROM PortfolioProfile..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProfile..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Break things down by continent

-- Showing Countries with Highest Death Count per Population
SELECT continent, MAX(total_deaths) as TotalDeathCount
FROM PortfolioProfile..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT date , SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths ,SUM(new_deaths)/Nullif(SUM(new_cases),0)*100 as DeathPercentage
FROM PortfolioProfile..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- Looking at Total Population vs Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From PortfolioProfile..CovidDeaths dea
Join PortfolioProfile..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location  Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProfile..CovidDeaths dea
JOIN PortfolioProfile..CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;

-- USE CTE

With PopvsVac (continent, location, date , population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location  Order by dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProfile..CovidDeaths dea
INNER JOIN PortfolioProfile..CovidVaccination vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

)
SELECT * ,(RollingPeopleVaccinated/population)*100
FROM PopvsVac