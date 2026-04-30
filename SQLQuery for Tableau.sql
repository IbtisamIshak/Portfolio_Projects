/* Queries used for tableau project */

-- 1.

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths
, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as mortality_rate
FROM portfolio_project..covid_deaths
WHERE continent is not null
ORDER BY 1,2

--Double-check the data provided.
--Compare the numbers with the data that has no country specifications

--SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths
--, SUM(CAST(new_deaths as int))/SUM(new_cases) as mortality_rate
--FROM portfolio_project..covid_deaths
--WHERE location = 'World'
--ORDER BY 1,2

-- 2.

--We extract this data as they are not included in the above queries and to stay consistent.
--European Union is a part of Europe

SELECT location, SUM(CAST(new_deaths as int)) as total_death_count
FROM portfolio_project..covid_deaths
WHERE continent is null
AND location not in ('World', 'European Union', 'International')
GROUP BY location
ORDER BY total_death_count DESC

-- 3.

SELECT location, population, MAX(total_cases) as highest_infection_count
, Max((total_cases/population))*100 as percent_population_infected
FROM portfolio_project..covid_deaths
GROUP BY location, population
ORDER BY percent_population_infected DESC

-- 4.

SELECT location, date, population, MAX(total_cases) as highest_infection_count
, Max((total_cases/population))*100 as percent_population_infected
FROM portfolio_project..covid_deaths
GROUP BY location, population, date
ORDER BY percent_population_infected DESC
