--Lets scan through covid deaths table

SELECT *
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
ORDER BY 3,4

--Select data that we are going to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM portfolio_project..covid_deaths
WHERE location = 'Malaysia'
AND continent is not NULL
ORDER BY date

--Looking at Total Cases vs Population
--Shows what percentage of population contracted covid

SELECT location, date, total_cases, population, (total_cases/population)*100 as percent_population_infected
FROM portfolio_project..covid_deaths
WHERE location = 'Malaysia'
AND continent is not NULL
ORDER BY date

--Looking at Countries with the Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
GROUP BY location, population
ORDER BY percent_population_infected DESC

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as total_death_count
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
GROUP BY location
ORDER BY total_death_count DESC

--Let's break things down by Continent

--Showing Continents with Highest Death Count per Population

SELECT continent, MAX(cast(total_deaths as int)) as total_death_count
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
GROUP BY continent
ORDER BY total_death_count DESC

--Global numbers by date

SELECT date, SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths
, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
GROUP BY date
ORDER BY 1, 2

--Total Global numbers 
SELECT SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_new_deaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as death_percentage
FROM portfolio_project..covid_deaths
WHERE continent is not NULL
ORDER BY 1, 2

--Lets scan through covid vaccinations table
SELECT *
FROM portfolio_project..covid_vaccinations
ORDER BY 3,4

--Join the tables
SELECT *
FROM portfolio_project..covid_deaths dea
JOIN portfolio_project..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

--Looking at Total Populations vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as rolling_people_vaccinated --adds up new vaccinations with the numbers from the day before
FROM portfolio_project..covid_deaths dea
JOIN portfolio_project..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Use CTE

With PopvsVac (Continent, location, date, population, new_vaccinations, rolling_people_vaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as rolling_people_vaccinated --adds up new vaccinations with the numbers from the day before
FROM portfolio_project..covid_deaths dea
JOIN portfolio_project..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, (rolling_people_vaccinated/population)*100 as vaccinated_percentage
FROM PopvsVac

--Temp table

DROP TABLE if exists #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric,
New_Vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as rolling_people_vaccinated --adds up new vaccinations with the numbers from the day before
FROM portfolio_project..covid_deaths dea
JOIN portfolio_project..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *, (rolling_people_vaccinated/population)*100 as vaccinated_percentage
FROM #percent_population_vaccinated

--Creating view to store data for later visualization

CREATE VIEW percent_population_vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as rolling_people_vaccinated --adds up new vaccinations with the numbers from the day before
FROM portfolio_project..covid_deaths dea
JOIN portfolio_project..covid_vaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *
FROM percent_population_vaccinated